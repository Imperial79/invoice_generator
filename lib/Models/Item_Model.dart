import 'dart:convert';

import 'package:invoice_generator/Resources/constants.dart';

class ItemModel {
  int id = 0;
  String itemName = "";
  String hsnCode = "";
  double qty = 0;
  String unit = "";
  double price = 0;
  double amount = 0;
  ItemModel({
    required this.id,
    required this.itemName,
    required this.hsnCode,
    required this.qty,
    required this.unit,
    required this.price,
    required this.amount,
  });

  ItemModel copyWith({
    int? id,
    String? itemName,
    String? hsnCode,
    double? qty,
    String? unit,
    double? price,
    double? amount,
  }) {
    return ItemModel(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      hsnCode: hsnCode ?? this.hsnCode,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'hsnCode': hsnCode,
      'qty': qty,
      'unit': unit,
      'price': price,
      'amount': amount,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id']?.toInt() ?? 0,
      itemName: map['itemName'] ?? '',
      hsnCode: map['hsnCode'] ?? '',
      qty: parseToDouble(map['qty']),
      unit: map['unit'] ?? '',
      price: parseToDouble(map['price']),
      amount: parseToDouble(map['amount']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemModel.fromJson(String source) =>
      ItemModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ItemModel(id: $id, itemName: $itemName, hsnCode: $hsnCode, qty: $qty, unit: $unit, price: $price, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemModel &&
        other.id == id &&
        other.itemName == itemName &&
        other.hsnCode == hsnCode &&
        other.qty == qty &&
        other.unit == unit &&
        other.price == price &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        itemName.hashCode ^
        hsnCode.hashCode ^
        qty.hashCode ^
        unit.hashCode ^
        price.hashCode ^
        amount.hashCode;
  }
}
