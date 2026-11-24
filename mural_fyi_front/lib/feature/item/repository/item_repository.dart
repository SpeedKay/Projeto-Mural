import '../../../core/api/api_client.dart';

import '../model/item_create_request.dart';
import '../model/item_model.dart';

abstract interface class ItemRepository {
  Future<List<ItemModel>> findAll();

  Future<List<ItemModel>> findByName(String name);

  Future<ItemModel> create(ItemCreateRequest request);

  Future<void> update(int id, ItemCreateRequest request);

  Future<void> markAsRedeemed(int id);

  Future<void> delete(int id);
}

class HttpItemRepository implements ItemRepository {
  const HttpItemRepository(this._apiClient);

  final ApiClient _apiClient;

  List<ItemModel> _parseItems(dynamic data) =>
      (data as List<dynamic>)
          .map(
            (entry) => ItemModel.fromJson(
              entry as Map<String, dynamic>,
            ),
          )
          .toList();

  @override
  Future<List<ItemModel>> findAll() async {
    return _parseItems(await _apiClient.get('/items'));
  }

  @override
  Future<List<ItemModel>> findByName(String name) async {
    return _parseItems(
      await _apiClient.get(
        '/items',
        queryParameters: {'name': name},
      ),
    );
  }

  @override
  Future<ItemModel> create(ItemCreateRequest request) async {
    final data = await _apiClient.post(
      '/items',
      request.toJson(),
    );

    return ItemModel.fromJson(
      data as Map<String, dynamic>,
    );
  }

  @override
  Future<void> update(
    int id,
    ItemCreateRequest request,
  ) async {
    await _apiClient.patch('/items/$id', {
      ...request.toJson(),
      'imgUrl': request.imgUrl ?? '',
    });
  }

  @override
  Future<void> markAsRedeemed(int id) async {
    await _apiClient.patch('/items/$id/redeem');
  }

  @override
  Future<void> delete(int id) async {
    await _apiClient.delete('/items/$id');
  }
}