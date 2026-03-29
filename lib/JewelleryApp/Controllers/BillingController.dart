import 'package:flutter/material.dart';
import '../Models/BillingModel.dart';
import 'InventoryController.dart';
import '../../Models/Invoice_Model.dart';
import '../../Models/Item_Model.dart';
import '../../Helper/database_service.dart';

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

  void updateCustomerPhone(String phone) {
    currentTab.customerPhone = phone;
    notifyListeners();
  }

  void updateCustomerAddress(String address) {
    currentTab.customerAddress = address;
    notifyListeners();
  }

  void updateDefaultMetalRate(double rate) {
    currentTab.defaultMetalRate = rate;
    notifyListeners();
  }

  // 📝 NEW: Complete Bill & Save Invoice & Sync with Inventory
  Future<InvoiceModel?> completeCurrentBill(InventoryController inventory) async {
    if (currentTab.cartItems.isEmpty) return null;

    final invoiceId = "INV-${DateTime.now().millisecondsSinceEpoch}";
    final List<ItemModel> invoiceItems = [];

    // 1. Convert CartItems to ItemModels for persistence/PDF
    for (int i = 0; i < currentTab.cartItems.length; i++) {
      final cartItem = currentTab.cartItems[i];

      // Reduce stock if applicable
      if (cartItem.sku != "AUTO") {
        inventory.updateStockForSKU(cartItem.sku, cartItem.weight);
      }

      invoiceItems.add(ItemModel(
        id: i + 1,
        itemName: "${cartItem.name} (${cartItem.sku})",
        hsnCode: "", // Add if needed later
        qty: 1, // Individual items for jewellery usually
        unit: "Pcs",
        price: cartItem.metalValue + (cartItem.makingType == MakingChargeType.fixed ? cartItem.makingValue : (cartItem.metalValue * cartItem.makingValue / 100)),
        amount: cartItem.total,
        gst: cartItem.total * 0.03, // Consistent with our UI (3% GST)
      ));
    }

    // 2. Construct InvoiceModel
    final invoice = InvoiceModel(
      invoiceId: invoiceId,
      items: invoiceItems,
      forCustomer: true,
      customerName: currentTab.customerName,
      customerPhone: currentTab.customerPhone,
      customerAadhaar: "",
      customerPan: "",
      billingAddress: currentTab.customerAddress,
      grandTotal: currentTab.grandTotal,
      invoiceDate: DateTime.now(),
    );

    // 3. Save to Database
    await DatabaseService.instance.saveInvoice(invoice);

    // 4. Reset Tab after successful save
    currentTab.cartItems.clear();
    currentTab.customerName = "Walk-in Customer";
    currentTab.customerPhone = "";
    currentTab.customerAddress = "";
    notifyListeners();

    return invoice;
  }

  void clearCurrentCart() {
    currentTab.cartItems.clear();
    notifyListeners();
  }
}
