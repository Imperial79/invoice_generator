import 'dart:convert';

import 'package:prime_invoice/Resources/constants.dart';

class ItemModel {
  int id = 0;
  String itemName = "";
  String sku = "";
  double qty = 0;
  double weight = 0;
  String unit = "";
  double price = 0;
  double amount = 0;
  double gst = 0; // Effective GST percentage
  double metalGst = 0;
  double serviceGst = 0;
  double metalAmount = 0;
  double serviceAmount = 0;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.sku,
    required this.qty,
    required this.weight,
    required this.unit,
    required this.price,
    required this.amount,
    required this.gst,
    this.metalGst = 0,
    this.serviceGst = 0,
    this.metalAmount = 0,
    this.serviceAmount = 0,
  });

  ItemModel copyWith({
    int? id,
    String? itemName,
    String? sku,
    double? qty,
    double? weight,
    String? unit,
    double? price,
    double? amount,
    double? gst,
    double? metalGst,
    double? serviceGst,
    double? metalAmount,
    double? serviceAmount,
  }) {
    return ItemModel(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      sku: sku ?? this.sku,
      qty: qty ?? this.qty,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      amount: amount ?? this.amount,
      gst: gst ?? this.gst,
      metalGst: metalGst ?? this.metalGst,
      serviceGst: serviceGst ?? this.serviceGst,
      metalAmount: metalAmount ?? this.metalAmount,
      serviceAmount: serviceAmount ?? this.serviceAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'sku': sku,
      'qty': qty,
      'weight': weight,
      'unit': unit,
      'price': price,
      'amount': amount,
      'gst': gst,
      'metalGst': metalGst,
      'serviceGst': serviceGst,
      'metalAmount': metalAmount,
      'serviceAmount': serviceAmount,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: int.parse("${map['id']}"),
      itemName: map['itemName'] ?? '',
      sku: map['sku'] ?? map['hsnCode'] ?? '',
      qty: parseToDouble(map['qty']),
      weight: parseToDouble(map['weight']),
      unit: map['unit'] ?? '',
      price: parseToDouble(map['price']),
      amount: parseToDouble(map['amount']),
      gst: parseToDouble(map['gst']),
      metalGst: parseToDouble(map['metalGst']),
      serviceGst: parseToDouble(map['serviceGst']),
      metalAmount: parseToDouble(map['metalAmount']),
      serviceAmount: parseToDouble(map['serviceAmount']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemModel.fromJson(String source) =>
      ItemModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ItemModel(id: $id, itemName: $itemName, sku: $sku, qty: $qty, weight: $weight, unit: $unit, price: $price, amount: $amount, gst: $gst, metalGst: $metalGst, serviceGst: $serviceGst, metalAmount: $metalAmount, serviceAmount: $serviceAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemModel &&
        other.id == id &&
        other.itemName == itemName &&
        other.sku == sku &&
        other.qty == qty &&
        other.weight == weight &&
        other.unit == unit &&
        other.price == price &&
        other.amount == amount &&
        other.gst == gst &&
        other.metalGst == metalGst &&
        other.serviceGst == serviceGst &&
        other.metalAmount == metalAmount &&
        other.serviceAmount == serviceAmount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        itemName.hashCode ^
        sku.hashCode ^
        qty.hashCode ^
        weight.hashCode ^
        unit.hashCode ^
        price.hashCode ^
        amount.hashCode ^
        gst.hashCode ^
        metalGst.hashCode ^
        serviceGst.hashCode ^
        metalAmount.hashCode ^
        serviceAmount.hashCode;
  }
}
