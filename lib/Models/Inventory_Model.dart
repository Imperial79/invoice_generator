import 'dart:convert';

class InventoryModel {
  final int? id;
  final String sku;
  final String name;
  final String category; // Gold, Silver, Diamond
  final double weight; // In grams
  final String purity; // 22K, 18K etc
  final double makingCharges;
  final double stock; // Quantity in hand
  final double minStockAlert; // Threshold for low stock

  InventoryModel({
    this.id,
    this.sku = "",
    required this.name,
    required this.category,
    required this.weight,
    required this.purity,
    required this.makingCharges,
    required this.stock,
    this.minStockAlert = 2,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'weight': weight,
      'purity': purity,
      'makingCharges': makingCharges,
      'stock': stock,
      'minStockAlert': minStockAlert,
    };
  }

  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      id: map['id']?.toInt(),
      sku: map['sku'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Gold',
      weight: (map['weight'] ?? 0.0).toDouble(),
      purity: map['purity'] ?? '',
      makingCharges: (map['makingCharges'] ?? 0.0).toDouble(),
      stock: (map['stock'] ?? 0.0).toDouble(),
      minStockAlert: (map['minStockAlert'] ?? 2.0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory InventoryModel.fromJson(String source) =>
      InventoryModel.fromMap(json.decode(source));

  InventoryModel copyWith({
    int? id,
    String? sku,
    String? name,
    String? category,
    double? weight,
    String? purity,
    double? makingCharges,
    double? stock,
    double? minStockAlert,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      weight: weight ?? this.weight,
      purity: purity ?? this.purity,
      makingCharges: makingCharges ?? this.makingCharges,
      stock: stock ?? this.stock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
    );
  }
}
