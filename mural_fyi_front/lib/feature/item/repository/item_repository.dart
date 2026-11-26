import 'dart:typed_data';

import '../../../core/api/api_client.dart';

import '../model/item_category.dart';
import '../model/item_create_request.dart';
import '../model/item_update_request.dart';
import '../model/item_model.dart';
import '../model/item_page.dart';

abstract interface class ItemRepository {
  Future<ItemPage> search({
    String search = '',
    String location = '',
    ItemCategory? category,
    int page = 0,
  });

  Future<Uint8List> findPhoto(int id);

  Future<ItemModel> create(
      ItemCreateRequest request, {
        Uint8List? photo,
      });

  Future<void> update(
      int id,
      ItemUpdateRequest request, {
        Uint8List? photo,
      });

  Future<void> markAsRedeemed(int id);

  Future<void> delete(int id);
}

class HttpItemRepository implements ItemRepository {
  const HttpItemRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ItemPage> search({
    String search = '',
    String location = '',
    ItemCategory? category,
    int page = 0,
  }) async {
    final result = await _apiClient.get(
      '/items',
      queryParameters: {
        'search': search,
        'location': location,
        'page': '$page',
        'size': '20',
        if (category != null)
          'category': category.apiValue,
      },
    );

    return ItemPage.fromJson(
      result as Map<String, dynamic>,
    );
  }

  @override
  Future<Uint8List> findPhoto(int id) =>
      _apiClient.getBytes('/items/$id/photo');

  @override
  Future<ItemModel> create(
      ItemCreateRequest request, {
        Uint8List? photo,
      }) async {
    final result = await _apiClient.multipart(
      'POST',
      '/items',
      request.toJson(),
      photo: photo,
    );

    return ItemModel.fromJson(
      result as Map<String, dynamic>,
    );
  }

  @override
  Future<void> update(
      int id,
      ItemUpdateRequest request, {
        Uint8List? photo,
      }) async {
    await _apiClient.multipart(
      'PATCH',
      '/items/$id',
      request.toJson(),
      photo: photo,
    );
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