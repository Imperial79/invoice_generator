import 'dart:convert';

class InventoryItem {
  final String sku;
  final String name;
  final String category;
  final String purity;
  double weight;
  int stock;

  InventoryItem({
    required this.sku,
    required this.name,
    required this.category,
    required this.purity,
    required this.weight,
    required this.stock,
  });

  String get status {
    if (stock > 5) return "In Stock";
    if (stock > 0) return "Low Stock";
    return "Out of Stock";
  }

  void sell(double sellWeight) {
    if (stock > 0) stock--;
  }

  Map<String, dynamic> toMap() {
    return {
      'sku': sku,
      'name': name,
      'category': category,
      'purity': purity,
      'weight': weight,
      'stock': stock,
    };
  }

  String toJson() => json.encode(toMap());

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      sku: map['sku'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      purity: map['purity'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      stock: map['stock'] ?? 0,
    );
  }

  factory InventoryItem.fromJson(String source) => 
      InventoryItem.fromMap(json.decode(source));
}
