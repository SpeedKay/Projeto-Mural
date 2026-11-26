import 'dart:async';

import 'package:flutter/foundation.dart';

import '../model/item_create_request.dart';
import '../model/item_update_request.dart';
import '../model/item_category.dart';
import '../model/item_model.dart';
import '../repository/item_repository.dart';

class ItemViewModel extends ChangeNotifier {
  ItemViewModel(this._repository);

  final ItemRepository _repository;

  List<ItemModel> _items = [];

  String _currentSearch = '';
  String _currentLocation = '';

  ItemCategory? _currentCategory;

  bool _isLoading = false;
  bool _disposed = false;

  String? _errorMessage;

  int _page = 0;
  int _totalPages = 0;
  int _totalElements = 0;
  int _loadVersion = 0;

  Timer? _debounce;

  final Set<int> _busyItems = {};

  List<ItemModel> get items => List.unmodifiable(_items);

  String get currentSearch => _currentSearch;

  String get currentLocation => _currentLocation;

  ItemCategory? get currentCategory => _currentCategory;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get totalElements => _totalElements;

  bool get hasMore => _page + 1 < _totalPages;

  bool isItemBusy(int id) => _busyItems.contains(id);

  void _emit() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _scheduleSearch() {
    _debounce?.cancel();

    // Invalida respostas referentes a filtros anteriores.
    ++_loadVersion;

    _items = [];
    _page = 0;
    _totalPages = 0;
    _totalElements = 0;

    _isLoading = true;
    _errorMessage = null;

    _emit();

    _debounce = Timer(
      const Duration(milliseconds: 350),
      loadItems,
    );
  }

  void searchItems(String value) {
    _currentSearch = value.trim();
    _scheduleSearch();
  }

  void filterByLocation(String value) {
    _currentLocation = value.trim();
    _scheduleSearch();
  }

  void filterByCategory(ItemCategory? value) {
    _currentCategory = value;
    _scheduleSearch();
  }

  void clearFilters() {
    _currentSearch = '';
    _currentLocation = '';
    _currentCategory = null;

    _scheduleSearch();
  }

  Future<void> loadItems() async {
    _debounce?.cancel();
    await _load(0);
  }

  Future<void> loadMore() async {
    if (!_isLoading && hasMore) {
      await _load(_page + 1);
    }
  }

  Future<void> _load(int page) async {
    if (_disposed) return;

    final version = ++_loadVersion;

    _isLoading = true;
    _errorMessage = null;

    _emit();

    try {
      final result = await _repository.search(
        search: _currentSearch,
        location: _currentLocation,
        category: _currentCategory,
        page: page,
      );

      if (!_disposed && version == _loadVersion) {
        _items = page == 0
            ? result.items
            : [..._items, ...result.items];

        _page = result.page;
        _totalPages = result.totalPages;
        _totalElements = result.totalElements;
      }
    } catch (error) {
      if (version == _loadVersion) {
        _errorMessage = error.toString();
      }
    } finally {
      if (version == _loadVersion) {
        _isLoading = false;
        _emit();
      }
    }
  }

  Future<Uint8List> findPhoto(int id) =>
      _repository.findPhoto(id);

  Future<ItemModel> createItem(
      ItemCreateRequest request, {
        Uint8List? photo,
      }) async {
    final result = await _repository.create(
      request,
      photo: photo,
    );

    await loadItems();

    return result;
  }

  Future<void> updateItem(
      int id,
      ItemUpdateRequest request, {
        Uint8List? photo,
      }) =>
      _mutate(
        id,
            () => _repository.update(
          id,
          request,
          photo: photo,
        ),
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
      throw StateError('Operação em andamento.');
    }

    _emit();

    try {
      await operation();
      await loadItems();
    } finally {
      _busyItems.remove(id);
      _emit();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    ++_loadVersion;

    super.dispose();
  }
}