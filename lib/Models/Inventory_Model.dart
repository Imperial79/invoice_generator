import 'dart:convert';

class InventoryModel {
  final int? id;
  final String sku;
  final String name;
  final String category; // Gold, Silver, Diamond
  final double weightStock; // Total Weight in grams in inventory
  final String purity; // 22K, 18K etc
  final double makingCharges;
  final String makingChargesType; // Fixed, Percent
  final double pieceStock; // Total Quantity/Pieces in hand
  final double minStockAlert; // Threshold for low stock

  InventoryModel({
    this.id,
    this.sku = "",
    required this.name,
    required this.category,
    required this.weightStock,
    required this.purity,
    required this.makingCharges,
    this.makingChargesType = 'Fixed',
    required this.pieceStock,
    this.minStockAlert = 2,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'weight': weightStock,
      'purity': purity,
      'makingCharges': makingCharges,
      'makingChargesType': makingChargesType,
      'stock': pieceStock,
      'minStockAlert': minStockAlert,
    };
  }

  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      id: map['id']?.toInt(),
      sku: map['sku'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Gold',
      weightStock: (map['weight'] ?? 0.0).toDouble(),
      purity: map['purity'] ?? '',
      makingCharges: (map['makingCharges'] ?? 0.0).toDouble(),
      makingChargesType: map['makingChargesType'] ?? 'Fixed',
      pieceStock: (map['stock'] ?? 0.0).toDouble(),
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
    double? weightStock,
    String? purity,
    double? makingCharges,
    String? makingChargesType,
    double? pieceStock,
    double? minStockAlert,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      weightStock: weightStock ?? this.weightStock,
      purity: purity ?? this.purity,
      makingCharges: makingCharges ?? this.makingCharges,
      makingChargesType: makingChargesType ?? this.makingChargesType,
      pieceStock: pieceStock ?? this.pieceStock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
    );
  }
}
