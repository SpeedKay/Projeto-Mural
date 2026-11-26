import 'item_category.dart';

class ItemUpdateRequest {
  const ItemUpdateRequest({
    this.name,
    this.description,
    this.category,
    this.localFound,
    this.timeFound,
    this.redeemLocal,
    required this.version,
    this.removePhoto = false,
  });

  final String? name;
  final String? description;
  final String? localFound;
  final String? redeemLocal;
  final ItemCategory? category;
  final DateTime? timeFound;
  final bool removePhoto;
  final int version;

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (category != null) 'category': category!.apiValue,
    if (localFound != null) 'localFound': localFound,
    if (timeFound != null)
      'timeFound': timeFound!.toIso8601String().split('T').first,
    if (redeemLocal != null) 'redeemLocal': redeemLocal,
    'removePhoto': removePhoto,
    'version': version,
  };
}