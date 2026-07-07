/// A product the store sells, matching the backend ItemResponse.
class Item {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final int stockQuantity;

  Item({
    this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stockQuantity,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as int?,
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        stockQuantity: json['stockQuantity'] as int? ?? 0,
      );

  /// Body for create / update requests (matches ItemRequest).
  Map<String, dynamic> toRequestJson() => {
        'name': name,
        'description': description,
        'price': price,
        'stockQuantity': stockQuantity,
      };
}
