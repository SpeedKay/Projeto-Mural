import 'item_category.dart';
import 'item_status.dart';

class ItemModel {
  const ItemModel({
    required this.itemId,
    required this.name,
    required this.description,
    required this.category,
    required this.localFound,
    required this.timeFound,
    required this.redeemLocal,
    required this.imgUrl,
    required this.status,
    this.hasPhoto = false,
    this.version = 0,
  });

  final int itemId;
  final String name;
  final String description;
  final ItemCategory category;
  final String localFound;
  final DateTime timeFound;
  final String redeemLocal;

  final String? imgUrl;

  final bool hasPhoto;
  final int version;
  final ItemStatus status;

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      itemId: (json['itemId'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      category: ItemCategory.fromApi(
        json['category'] as String,
      ),
      localFound: json['localFound'] as String,
      timeFound: DateTime.parse(
        json['timeFound'] as String,
      ),
      redeemLocal: json['redeemLocal'] as String,
      imgUrl: json['imgUrl'] as String?,
      hasPhoto: json['hasPhoto'] == true,
      version: (json['version'] as num?)?.toInt() ?? 0,
      status: ItemStatus.fromApi(
        json['status'] as String,
      ),
    );
  }
}