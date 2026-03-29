import 'package:flutter/material.dart';
import '../Models/BillingModel.dart';
import 'InventoryController.dart';

class BillingController extends ChangeNotifier {
  // Static instance to persist open tabs across sessions/navigation
  static final BillingController _instance = BillingController._();
  BillingController._();
  factory BillingController() => _instance;

  final List<BillingTab> tabs = [
    BillingTab(id: "tab1", customerName: "Main Customer", cartItems: []),
  ];

  int currentTabIndex = 0;

  BillingTab get currentTab => tabs[currentTabIndex];

  void addNewTab() {
    final newId = "tab${tabs.length + 1}";
    tabs.add(BillingTab(id: newId, customerName: "New Customer", cartItems: []));
    currentTabIndex = tabs.length - 1;
    notifyListeners();
  }

  void switchTab(int index) {
    if (index >= 0 && index < tabs.length) {
      currentTabIndex = index;
      notifyListeners();
    }
  }

  void removeTab(int index) {
    if (tabs.length > 1) {
      tabs.removeAt(index);
      if (currentTabIndex >= tabs.length) {
        currentTabIndex = tabs.length - 1;
      }
      notifyListeners();
    }
  }

  void addCartItem(CartItem item) {
    currentTab.cartItems.add(item);
    notifyListeners();
  }

  void removeCartItem(int index) {
    currentTab.cartItems.removeAt(index);
    notifyListeners();
  }

  void updateCustomerName(String name) {
    currentTab.customerName = name;
    notifyListeners();
  }

  // 📝 NEW: Complete Bill & Sync with Inventory
  void completeCurrentBill(InventoryController inventory) {
    if (currentTab.cartItems.isEmpty) return;

    // Adjust Inventory stock for each item in cart
    for (var cartItem in currentTab.cartItems) {
      // Only reduce stock if it came from the inventory (has a real SKU)
      if (cartItem.sku != "AUTO") {
        inventory.updateStockForSKU(cartItem.sku, cartItem.weight);
      }
    }

    // After adjust, we can clear the cart or remove the tab
    // Let's clear the cart but keep the tab for now
    currentTab.cartItems.clear();
    currentTab.customerName = "New Sale";
    notifyListeners();
  }

  void clearCurrentCart() {
    currentTab.cartItems.clear();
    notifyListeners();
  }
}
