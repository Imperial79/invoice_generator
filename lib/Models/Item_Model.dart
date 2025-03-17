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
  double gst = 0;
  ItemModel({
    required this.id,
    required this.itemName,
    required this.hsnCode,
    required this.qty,
    required this.unit,
    required this.price,
    required this.amount,
    required this.gst,
  });

  ItemModel copyWith({
    int? id,
    String? itemName,
    String? hsnCode,
    double? qty,
    String? unit,
    double? price,
    double? amount,
    double? gst,
  }) {
    return ItemModel(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      hsnCode: hsnCode ?? this.hsnCode,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      amount: amount ?? this.amount,
      gst: gst ?? this.gst,
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
      'gst': gst,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: int.parse("${map['id']}"),
      itemName: map['itemName'] ?? '',
      hsnCode: map['hsnCode'] ?? '',
      qty: parseToDouble(map['qty']),
      unit: map['unit'] ?? '',
      price: parseToDouble(map['price']),
      amount: parseToDouble(map['amount']),
      gst: parseToDouble(map['gst']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemModel.fromJson(String source) =>
      ItemModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ItemModel(id: $id, itemName: $itemName, hsnCode: $hsnCode, qty: $qty, unit: $unit, price: $price, amount: $amount, gst: $gst)';
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
        other.amount == amount &&
        other.gst == gst;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        itemName.hashCode ^
        hsnCode.hashCode ^
        qty.hashCode ^
        unit.hashCode ^
        price.hashCode ^
        amount.hashCode ^
        gst.hashCode;
  }
}
