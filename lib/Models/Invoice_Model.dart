import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:invoice_generator/Models/Item_Model.dart';

class InvoiceModel {
  String invoiceId = "";
  List<ItemModel> items = [];
  List<Map<String, dynamic>> taxList = [];
  bool forCustomer = false;
  String customerName = "";
  String customerPhone = "";
  String customerAadhaar = "";
  String customerPan = "";
  String billingAddress = "";
  InvoiceModel({
    required this.invoiceId,
    required this.items,
    required this.taxList,
    required this.forCustomer,
    required this.customerName,
    required this.customerPhone,
    required this.customerAadhaar,
    required this.customerPan,
    required this.billingAddress,
  });

  InvoiceModel copyWith({
    String? invoiceId,
    List<ItemModel>? items,
    List<Map<String, dynamic>>? taxList,
    bool? forCustomer,
    String? customerName,
    String? customerPhone,
    String? customerAadhaar,
    String? customerPan,
    String? billingAddress,
  }) {
    return InvoiceModel(
      invoiceId: invoiceId ?? this.invoiceId,
      items: items ?? this.items,
      taxList: taxList ?? this.taxList,
      forCustomer: forCustomer ?? this.forCustomer,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAadhaar: customerAadhaar ?? this.customerAadhaar,
      customerPan: customerPan ?? this.customerPan,
      billingAddress: billingAddress ?? this.billingAddress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoiceId': invoiceId,
      'items': items.map((x) => x.toMap()).toList(),
      'taxList': taxList,
      'forCustomer': forCustomer,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAadhaar': customerAadhaar,
      'customerPan': customerPan,
      'billingAddress': billingAddress,
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      invoiceId: map['invoiceId'] ?? '',
      items:
          List<ItemModel>.from(map['items']?.map((x) => ItemModel.fromMap(x))),
      taxList: List<Map<String, dynamic>>.from(map['taxList'] ?? []),
      forCustomer: map['forCustomer'] ?? false,
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerAadhaar: map['customerAadhaar'] ?? '',
      customerPan: map['customerPan'] ?? '',
      billingAddress: map['billingAddress'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory InvoiceModel.fromJson(String source) =>
      InvoiceModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'InvoiceModel(invoiceId: $invoiceId, items: $items, taxList: $taxList, forCustomer: $forCustomer, customerName: $customerName, customerPhone: $customerPhone, customerAadhaar: $customerAadhaar, customerPan: $customerPan, billingAddress: $billingAddress)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InvoiceModel &&
        other.invoiceId == invoiceId &&
        listEquals(other.items, items) &&
        listEquals(other.taxList, taxList) &&
        other.forCustomer == forCustomer &&
        other.customerName == customerName &&
        other.customerPhone == customerPhone &&
        other.customerAadhaar == customerAadhaar &&
        other.customerPan == customerPan &&
        other.billingAddress == billingAddress;
  }

  @override
  int get hashCode {
    return invoiceId.hashCode ^
        items.hashCode ^
        taxList.hashCode ^
        forCustomer.hashCode ^
        customerName.hashCode ^
        customerPhone.hashCode ^
        customerAadhaar.hashCode ^
        customerPan.hashCode ^
        billingAddress.hashCode;
  }
}
