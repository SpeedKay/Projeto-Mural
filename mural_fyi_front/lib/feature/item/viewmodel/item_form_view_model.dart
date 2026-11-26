import 'package:flutter/foundation.dart';

import '../model/item_model.dart';
import '../model/item_create_request.dart';
import '../model/item_update_request.dart';
import '../service/photo_picker_service.dart';

import 'item_view_model.dart';

class ItemFormViewModel extends ChangeNotifier {
  ItemFormViewModel(
      this._items,
      this._picker, {
        this.item,
      });

  final ItemViewModel _items;
  final PhotoPickerService _picker;
  final ItemModel? item;

  SelectedPhoto? _photo;

  bool _removePhoto = false;
  bool _isPicking = false;
  bool _isSaving = false;
  bool _disposed = false;

  String? _error;

  SelectedPhoto? get photo => _photo;

  bool get removePhoto => _removePhoto;

  bool get isPicking => _isPicking;

  bool get isSaving => _isSaving;

  String? get error => _error;

  void _emit() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> pickPhoto() async {
    if (_isPicking || _isSaving || _disposed) {
      return;
    }

    _isPicking = true;
    _error = null;

    _emit();

    try {
      final selected = await _picker.pick();

      if (selected != null && !_disposed) {
        _photo = selected;
        _removePhoto = false;
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      _isPicking = false;
      _emit();
    }
  }

  void clearPhoto() {
    if (_isSaving || _isPicking || _disposed) {
      return;
    }

    _photo = null;
    _removePhoto = true;

    _emit();
  }

  Future<bool> save(ItemCreateRequest data) async {
    if (_isSaving || _isPicking || _disposed) {
      return false;
    }

    _isSaving = true;
    _error = null;

    _emit();

    try {
      if (item == null) {
        await _items.createItem(
          data,
          photo: _photo?.bytes,
        );
      } else {
        final request = ItemUpdateRequest(
          name: data.name,
          description: data.description,
          category: data.category,
          localFound: data.localFound,
          timeFound: data.timeFound,
          redeemLocal: data.redeemLocal,
          version: item!.version,
          removePhoto: _removePhoto,
        );

        await _items.updateItem(
          item!.itemId,
          request,
          photo: _photo?.bytes,
        );
      }

      return true;
    } catch (error) {
      _error = error.toString();

      return false;
    } finally {
      _isSaving = false;

      _emit();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}