import 'item_category.dart';

class ItemCreateRequest {
  const ItemCreateRequest({
    required this.name,
    required this.description,
    required this.category,
    required this.localFound,
    required this.timeFound,
    required this.redeemLocal,
  });

  final String name;
  final String description;
  final ItemCategory category;
  final String localFound;
  final DateTime timeFound;
  final String redeemLocal;

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'category': category.apiValue,
    'localFound': localFound,
    'timeFound': timeFound.toIso8601String().split('T').first,
    'redeemLocal': redeemLocal,
  };
}