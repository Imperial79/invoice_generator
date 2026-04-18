import 'dart:convert';

class StockLogModel {
  final int? id;
  final int itemId;
  final String itemName;
  final String sku;
  final String action; // Credit, Debit
  final String type; // Sale, Manual, Return, Restock
  final double weight;
  final double pieces;
  final String notes;
  final DateTime date;

  StockLogModel({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.sku,
    required this.action,
    required this.type,
    required this.weight,
    required this.pieces,
    required this.notes,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'sku': sku,
      'action': action,
      'type': type,
      'weight': weight,
      'pieces': pieces,
      'notes': notes,
      'date': date.toIso8601String(),
    };
  }

  factory StockLogModel.fromMap(Map<String, dynamic> map) {
    return StockLogModel(
      id: map['id']?.toInt(),
      itemId: map['itemId']?.toInt() ?? 0,
      itemName: map['itemName'] ?? '',
      sku: map['sku'] ?? '',
      action: map['action'] ?? '',
      type: map['type'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      pieces: (map['pieces'] ?? 0.0).toDouble(),
      notes: map['notes'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }

  String toJson() => json.encode(toMap());

  factory StockLogModel.fromJson(String source) => StockLogModel.fromMap(json.decode(source));
}
