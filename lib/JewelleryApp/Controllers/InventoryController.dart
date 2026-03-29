import 'package:flutter/material.dart';
import '../Models/InventoryModel.dart';
import '../../Helper/database_service.dart';

class InventoryController extends ChangeNotifier {
  static final InventoryController _instance = InventoryController._();
  InventoryController._() {
    loadItems(); // Initial load
  }
  factory InventoryController() => _instance;

  final List<InventoryItem> items = [];

  // Validation State for UI
  String? nameError;
  String? skuError;
  String? weightError;

  Future<void> loadItems() async {
    try {
      final rows = await DatabaseService.instance.getAllInventoryRows();
      items.clear();
      for (var row in rows) {
        items.add(InventoryItem.fromJson(row['data'] as String));
      }
      // If DB is empty, add some defaults once or keep it empty
      if (items.isEmpty) {
        // _addDefaultItems(); // Optional: add dummy data on first run
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading inventory items: $e");
    }
  }

  void validate(String name, String sku, String weight) {
    nameError = name.trim().isEmpty ? "Product name is required" : null;
    skuError = sku.trim().isEmpty ? "SKU is required" : null;
    weightError = weight.trim().isEmpty ? "Weight is required" : null;
    notifyListeners();
  }

  bool get isValid => nameError == null && skuError == null && weightError == null;

  Future<void> addItem(InventoryItem item) async {
    items.insert(0, item);
    // Persist to local DB
    await DatabaseService.instance.saveInventoryItem({
      'sku': item.sku,
      'data': item.toJson(),
    });
    notifyListeners();
  }

  Future<void> updateStockForSKU(String sku, double weightSold) async {
    for (var item in items) {
      if (item.sku == sku) {
        if (item.stock > 0) {
          item.stock--;
          // Persist update
          await DatabaseService.instance.saveInventoryItem({
            'sku': item.sku,
            'data': item.toJson(),
          });
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

  List<InventoryItem> searchItems(String query) {
    if (query.isEmpty) return [];
    final q = query.toUpperCase();
    return items.where((item) {
      return item.sku.toUpperCase().contains(q) || 
             item.name.toUpperCase().contains(q);
    }).toList();
  }

  InventoryItem? findBySKU(String sku) {
    try {
      return items.firstWhere((e) => e.sku.toUpperCase() == sku.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteItem(String sku) async {
    items.removeWhere((e) => e.sku == sku);
    await DatabaseService.instance.deleteInventoryItem(sku);
    notifyListeners();
  }
}
