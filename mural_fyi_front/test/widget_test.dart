import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:mural_fyi_front/feature/item/model/item_category.dart';
import 'package:mural_fyi_front/feature/item/model/item_create_request.dart';
import 'package:mural_fyi_front/feature/item/model/item_update_request.dart';
import 'package:mural_fyi_front/feature/item/model/item_model.dart';
import 'package:mural_fyi_front/feature/item/model/item_page.dart';

import 'package:mural_fyi_front/feature/item/repository/item_repository.dart';
import 'package:mural_fyi_front/feature/item/viewmodel/item_view_model.dart';
import 'package:mural_fyi_front/feature/item/service/photo_compression_service.dart';

class FakeRepository implements ItemRepository {
  String lastSearch = '';
  String lastLocation = '';

  ItemCategory? lastCategory;

  int lastPage = -1;

  @override
  Future<ItemPage> search({
    String search = '',
    String location = '',
    ItemCategory? category,
    int page = 0,
  }) async {
    lastSearch = search;
    lastLocation = location;
    lastCategory = category;
    lastPage = page;

    return ItemPage(
      items: [],
      page: page,
      totalPages: 2,
      totalElements: 21,
    );
  }

  @override
  Future<Uint8List> findPhoto(int id) async =>
      Uint8List(0);

  @override
  Future<ItemModel> create(
      ItemCreateRequest request, {
        Uint8List? photo,
      }) async =>
      throw UnimplementedError();

  @override
  Future<void> update(
      int id,
      ItemUpdateRequest request, {
        Uint8List? photo,
      }) async =>
      throw UnimplementedError();

  @override
  Future<void> markAsRedeemed(int id) async =>
      throw UnimplementedError();

  @override
  Future<void> delete(int id) async =>
      throw UnimplementedError();
}

void main() {
  test(
    'Envia filtros combinados e carrega próxima página',
        () async {
      final repo = FakeRepository();
      final vm = ItemViewModel(repo);

      addTearDown(vm.dispose);

      vm.searchItems('USB');
      vm.filterByLocation('auditorio');
      vm.filterByCategory(ItemCategory.electronics);

      await vm.loadItems();

      expect(repo.lastSearch, 'USB');

      expect(repo.lastLocation, 'auditorio');

      expect(
        repo.lastCategory,
        ItemCategory.electronics,
      );

      expect(vm.totalElements, 21);
      expect(vm.hasMore, true);

      await vm.loadMore();

      expect(repo.lastPage, 1);
      expect(vm.hasMore, false);
    },
  );

  test(
    'PATCH omite campos ausentes e explicita remoção',
        () {
      expect(
        const ItemUpdateRequest(
          version: 0,
        ).toJson(),

        {
          'removePhoto': false,
          'version': 0,
        },
      );

      expect(
        const ItemUpdateRequest(
          version: 2,
          removePhoto: true,
        ).toJson(),

        {
          'removePhoto': true,
          'version': 2,
        },
      );
    },
  );

  test(
    'Comprime imagem preservando proporção e limites',
        () async {
      final original = img.Image(
        width: 1600,
        height: 1200,
      );

      final originalBytes = img.encodePng(original);

      const service = PhotoCompressionService();

      final compressed = await service.compress(
        originalBytes,
      );

      final decoded = img.decodeJpg(compressed);

      expect(decoded, isNotNull);

      expect(decoded!.width, 800);
      expect(decoded.height, 600);

      expect(
        compressed.length,
        lessThanOrEqualTo(
          PhotoCompressionService.maxOutputBytes,
        ),
      );
    },
  );

  test(
    'Rejeita arquivos que não são fotografias',
        () async {
      const service = PhotoCompressionService();

      await expectLater(
        service.compress(
          Uint8List.fromList([1, 2, 3, 4]),
        ),
        throwsA(isA<FormatException>()),
      );
    },
  );
}