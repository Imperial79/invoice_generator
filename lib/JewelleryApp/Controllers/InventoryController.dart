import 'package:flutter/material.dart';
import '../Models/InventoryModel.dart';

class InventoryController extends ChangeNotifier {
  // Static final so it persists between screens if they reuse the same instance or I can use a Singleton.
  // The user says "Controller", so I'll use a Singleton for the main data.
  static final InventoryController _instance = InventoryController._();
  InventoryController._();
  factory InventoryController() => _instance;

  final List<InventoryItem> items = [
    InventoryItem(sku: "G-101", name: "Wedding Band (Men)", category: "Gold", purity: "22K", weight: 8.5, stock: 12),
    InventoryItem(sku: "D-202", name: "Solitaire Ring", category: "Diamond", purity: "18K", weight: 2.1, stock: 3),
    InventoryItem(sku: "G-303", name: "Temple Necklace", category: "Gold", purity: "22K", weight: 45.0, stock: 2),
    InventoryItem(sku: "S-404", name: "Silver Bracelet", category: "Silver", purity: "925", weight: 15.0, stock: 10),
  ];

  // Validation State for UI
  String? nameError;
  String? skuError;
  String? weightError;

  void validate(String name, String sku, String weight) {
    nameError = name.trim().isEmpty ? "Product name is required" : null;
    skuError = sku.trim().isEmpty ? "SKU is required" : null;
    weightError = weight.trim().isEmpty ? "Weight is required" : null;
    notifyListeners();
  }

  bool get isValid => nameError == null && skuError == null && weightError == null;

  void addItem(InventoryItem item) {
    items.insert(0, item);
    notifyListeners();
  }

  void updateStockForSKU(String sku, double weightSold) {
    for (var item in items) {
      if (item.sku == sku) {
        if (item.stock > 0) {
          item.stock--;
          // For unique jewellery, weight is fixed. For bulk items (like coins), subtract.
          // Let's assume unique items stay in inventory unless stock is out.
          debugPrint("Stock updated for $sku: ${item.stock} left");
        }
        break;
      }
    }
    notifyListeners();
  }

  void resetValidation() {
    nameError = null;
    skuError = null;
    weightError = null;
    notifyListeners();
  }

  void clearFields() {
    resetValidation();
  }

  InventoryItem? findBySKU(String sku) {
    try {
      return items.firstWhere((e) => e.sku == sku);
    } catch (e) {
      return null;
    }
  }
}
