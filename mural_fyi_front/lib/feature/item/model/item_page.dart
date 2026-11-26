import 'item_model.dart';

class ItemPage {
  const ItemPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalElements,
  });

  final List<ItemModel> items;
  final int page;
  final int totalPages;
  final int totalElements;

  factory ItemPage.fromJson(Map<String, dynamic> json) {
    return ItemPage(
      items: List.unmodifiable(
        (json['content'] as List).map(
              (entry) => ItemModel.fromJson(
            entry as Map<String, dynamic>,
          ),
        ),
      ),
      page: (json['page'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
    );
  }
}