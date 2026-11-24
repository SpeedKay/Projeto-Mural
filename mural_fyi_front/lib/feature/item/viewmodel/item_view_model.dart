import 'package:flutter/foundation.dart';

import '../model/item_create_request.dart';
import '../model/item_model.dart';
import '../repository/item_repository.dart';

class ItemViewModel extends ChangeNotifier {
  ItemViewModel(this._repository);

  final ItemRepository _repository;

  List<ItemModel> items = [];

  bool isLoading = false;
  String? errorMessage;
  String currentSearch = '';

  int _loadVersion = 0;

  final Set<int> _busyItems = {};

  bool isItemBusy(int id) => _busyItems.contains(id);

  Future<void> loadItems() async {
    final version = ++_loadVersion;
    final search = currentSearch;

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      final result = search.isEmpty
          ? await _repository.findAll()
          : await _repository.findByName(search);

      if (version == _loadVersion) {
        items = result;
      }
    } catch (error) {
      if (version == _loadVersion) {
        errorMessage = error.toString();
      }
    } finally {
      if (version == _loadVersion) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> searchItems(String name) async {
    currentSearch = name.trim();
    await loadItems();
  }

  Future<ItemModel> createItem(
    ItemCreateRequest request,
  ) async {
    final created = await _repository.create(request);

    await loadItems();

    return created;
  }

  Future<void> updateItem(
    int id,
    ItemCreateRequest request,
  ) =>
      _mutate(
        id,
        () => _repository.update(id, request),
      );

  Future<void> markAsRedeemed(int id) =>
      _mutate(
        id,
        () => _repository.markAsRedeemed(id),
      );

  Future<void> deleteItem(int id) =>
      _mutate(
        id,
        () => _repository.delete(id),
      );

  Future<void> _mutate(
    int id,
    Future<void> Function() operation,
  ) async {
    if (!_busyItems.add(id)) {
      throw StateError(
        'Já existe uma operação em andamento.',
      );
    }

    notifyListeners();

    try {
      await operation();
      await loadItems();
    } finally {
      _busyItems.remove(id);
      notifyListeners();
    }
  }
}