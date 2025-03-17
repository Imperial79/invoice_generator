import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:invoice_generator/Models/Item_Model.dart';
import 'package:invoice_generator/Resources/constants.dart';

class InvoiceModel {
  String invoiceId = "";
  List<ItemModel> items = [];
  bool forCustomer = false;
  String customerName = "";
  String customerPhone = "";
  String customerAadhaar = "";
  String customerPan = "";
  String billingAddress = "";
  double grandTotal = 0;
  DateTime? invoiceDate;

  InvoiceModel({
    required this.invoiceId,
    required this.items,
    required this.forCustomer,
    required this.customerName,
    required this.customerPhone,
    required this.customerAadhaar,
    required this.customerPan,
    required this.billingAddress,
    required this.grandTotal,
    this.invoiceDate,
  });

  InvoiceModel copyWith({
    String? invoiceId,
    List<ItemModel>? items,
    bool? forCustomer,
    String? customerName,
    String? customerPhone,
    String? customerAadhaar,
    String? customerPan,
    String? billingAddress,
    double? grandTotal,
    DateTime? invoiceDate,
  }) {
    return InvoiceModel(
      invoiceId: invoiceId ?? this.invoiceId,
      items: items ?? this.items,
      forCustomer: forCustomer ?? this.forCustomer,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAadhaar: customerAadhaar ?? this.customerAadhaar,
      customerPan: customerPan ?? this.customerPan,
      billingAddress: billingAddress ?? this.billingAddress,
      grandTotal: grandTotal ?? this.grandTotal,
      invoiceDate: invoiceDate ?? this.invoiceDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoiceId': invoiceId,
      'items': items.map((x) => x.toMap()).toList(),
      'forCustomer': forCustomer,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAadhaar': customerAadhaar,
      'customerPan': customerPan,
      'billingAddress': billingAddress,
      'grandTotal': grandTotal,
      'invoiceDate': invoiceDate?.millisecondsSinceEpoch,
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      invoiceId: map['invoiceId'] ?? '',
      items:
          List<ItemModel>.from(map['items']?.map((x) => ItemModel.fromMap(x))),
      forCustomer: map['forCustomer'] ?? false,
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerAadhaar: map['customerAadhaar'] ?? '',
      customerPan: map['customerPan'] ?? '',
      billingAddress: map['billingAddress'] ?? '',
      grandTotal: parseToDouble(map['grandTotal']),
      invoiceDate: map['invoiceDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['invoiceDate'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory InvoiceModel.fromJson(String source) =>
      InvoiceModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'InvoiceModel(invoiceId: $invoiceId, items: $items, forCustomer: $forCustomer, customerName: $customerName, customerPhone: $customerPhone, customerAadhaar: $customerAadhaar, customerPan: $customerPan, billingAddress: $billingAddress, grandTotal: $grandTotal, invoiceDate: $invoiceDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InvoiceModel &&
        other.invoiceId == invoiceId &&
        listEquals(other.items, items) &&
        other.forCustomer == forCustomer &&
        other.customerName == customerName &&
        other.customerPhone == customerPhone &&
        other.customerAadhaar == customerAadhaar &&
        other.customerPan == customerPan &&
        other.billingAddress == billingAddress &&
        other.grandTotal == grandTotal &&
        other.invoiceDate == invoiceDate;
  }

  @override
  int get hashCode {
    return invoiceId.hashCode ^
        items.hashCode ^
        forCustomer.hashCode ^
        customerName.hashCode ^
        customerPhone.hashCode ^
        customerAadhaar.hashCode ^
        customerPan.hashCode ^
        billingAddress.hashCode ^
        grandTotal.hashCode ^
        invoiceDate.hashCode;
  }
}
