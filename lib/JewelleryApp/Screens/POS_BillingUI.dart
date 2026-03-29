import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../Theme.dart';
import '../Widgets/JewelleryCard.dart';
import '../Models/BillingModel.dart';
import '../Models/InventoryModel.dart';
import '../Controllers/BillingController.dart';
import '../Controllers/InventoryController.dart';

class POSBillingUI extends StatefulWidget {
  const POSBillingUI({super.key});

  @override
  State<POSBillingUI> createState() => _POSBillingUIState();
}

class _POSBillingUIState extends State<POSBillingUI> {
  final BillingController _billing = BillingController();
  final InventoryController _inventory = InventoryController();

  @override
  void initState() {
    super.initState();
    _billing.addListener(() {
      if (mounted) setState(() {});
    });
    _inventory.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _showAddItemToCartDialog({InventoryItem? preloadedItem}) {
    String name = preloadedItem?.name ?? "";
    String sku = preloadedItem?.sku ?? "AUTO";
    double weight = preloadedItem?.weight ?? 0.0;
    double rate = 5800.0;
    MakingChargeType makingType = MakingChargeType.percentage;
    double makingValue = 12.0;

    final nameCtrl = TextEditingController(text: name);
    final skuCtrl = TextEditingController(text: sku);
    final weightCtrl = TextEditingController(
      text: weight > 0 ? weight.toString() : "",
    );

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            backgroundColor: theme.cardTheme.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ADD ITEM TO CART",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // SKU Search Feature
                  if (preloadedItem == null) ...[
                    _formLabel("Search Inventory by SKU"),
                    TextField(
                      onChanged: (v) {
                        final found = _inventory.findBySKU(v.toUpperCase());
                        if (found != null && found.stock > 0) {
                          setDialogState(() {
                            name = found.name;
                            sku = found.sku;
                            weight = found.weight;
                            nameCtrl.text = name;
                            skuCtrl.text = sku;
                            weightCtrl.text = weight.toString();
                          });
                        }
                      },
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: "Enter SKU (e.g. G-101)",
                        prefixIcon: Icon(LucideIcons.search, size: 18),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),
                  ],

                  _formLabel("Product Name"),
                  TextField(
                    controller: nameCtrl,
                    onChanged: (v) => name = v,
                    decoration: const InputDecoration(
                      hintText: "Enter item name",
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _formLabel("Weight (g)"),
                            TextField(
                              controller: weightCtrl,
                              onChanged: (v) =>
                                  weight = double.tryParse(v) ?? 0.0,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                hintText: "0.00",
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _formLabel("Metal Rate (per g)"),
                            TextField(
                              onChanged: (v) =>
                                  rate = double.tryParse(v) ?? 5800.0,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: "₹5800",
                                prefixText: "₹",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _formLabel("Making Charge Type"),
                  Row(
                    children: [
                      _toggleButton(
                        "PERCENTAGE (%)",
                        makingType == MakingChargeType.percentage,
                        () => setDialogState(
                          () => makingType = MakingChargeType.percentage,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _toggleButton(
                        "FIXED (₹)",
                        makingType == MakingChargeType.fixed,
                        () => setDialogState(
                          () => makingType = MakingChargeType.fixed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _formLabel(
                    makingType == MakingChargeType.percentage
                        ? "Making Percentage (%)"
                        : "Making Charge (Amount)",
                  ),
                  TextField(
                    onChanged: (v) => makingValue = double.tryParse(v) ?? 0.0,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: makingType == MakingChargeType.percentage
                          ? "12%"
                          : "₹1500",
                    ),
                  ),
                  const SizedBox(height: 48),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("CANCEL"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (name.isNotEmpty && weight > 0) {
                              _billing.addCartItem(
                                CartItem(
                                  sku: sku,
                                  name: name,
                                  weight: weight,
                                  metalRate: rate,
                                  makingType: makingType,
                                  makingValue: makingValue,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: const Text("ADD TO CART"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _toggleButton(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? JewelleryTheme.gold : Colors.transparent,
            border: Border.all(
              color: isActive
                  ? JewelleryTheme.gold
                  : Colors.grey.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("MULTI-CUSTOMER BILLING"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.printer, size: 20),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildTabsHeader(),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (v) {
                                  // Live search for cart add?
                                  // For now, it searches from inventory only
                                },
                                decoration: InputDecoration(
                                  hintText: "Enter SKU Code or Search Item...",
                                  prefixIcon: const Icon(
                                    LucideIcons.search,
                                    size: 20,
                                  ),
                                  fillColor: theme.cardTheme.color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _showAddItemToCartDialog,
                              icon: const Icon(
                                LucideIcons.circlePlus,
                                size: 18,
                              ),
                              label: const Text("ADD ITEM"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Expanded(
                          child: JewelleryCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                _buildCartHeader(),
                                const Divider(height: 1),
                                Expanded(
                                  child: _billing.currentTab.cartItems.isEmpty
                                      ? _emptyCartView(theme)
                                      : ListView.separated(
                                          itemCount: _billing
                                              .currentTab
                                              .cartItems
                                              .length,
                                          separatorBuilder: (context, index) =>
                                              const Divider(height: 1),
                                          itemBuilder: (context, index) =>
                                              _cartItemRow(
                                                _billing
                                                    .currentTab
                                                    .cartItems[index],
                                                index,
                                              ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Side: Summary Table
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: isDark ? theme.colorScheme.surface : Colors.white,
                    border: Border(
                      left: BorderSide(
                        color:
                            theme.dividerTheme.color ??
                            theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Billing Summary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _priceRow(
                        "Subtotal (Items)",
                        "₹${_billing.currentTab.subTotal.toStringAsFixed(2)}",
                      ),
                      _priceRow(
                        "Metal Value",
                        "₹${_billing.currentTab.totalMetal.toStringAsFixed(2)}",
                      ),
                      _priceRow(
                        "Total Making Charge",
                        "₹${_billing.currentTab.totalMaking.toStringAsFixed(2)}",
                      ),
                      _priceRow(
                        "GST (3%)",
                        "₹${_billing.currentTab.tax.toStringAsFixed(2)}",
                      ),

                      const Spacer(),

                      const Divider(height: 48),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Grand Total",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            "₹${_billing.currentTab.grandTotal.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: JewelleryTheme.gold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_billing.currentTab.cartItems.isNotEmpty) {
                              _billing.completeCurrentBill(_inventory);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Bill successfully generated & stock adjusted!",
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text("GENERATE INVOICE"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCartView(ThemeData theme) {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.shoppingBasket, size: 48),
            const SizedBox(height: 16),
            Text(
              "Empty Cart",
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerTheme.color ?? theme.colorScheme.outline,
          ),
        ),
      ),
      child: Row(
        children: [
          ..._billing.tabs.asMap().entries.map((entry) {
            int idx = entry.key;
            BillingTab tab = entry.value;
            bool isActive = _billing.currentTabIndex == idx;
            return _tabItem(tab.customerName, isActive, idx);
          }),

          IconButton(
            onPressed: () => _billing.addNewTab(),
            icon: const Icon(LucideIcons.plus, color: JewelleryTheme.gold),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(String name, bool isActive, int index) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _billing.switchTab(index),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? JewelleryTheme.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isActive
                  ? JewelleryTheme.gold
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : Colors.grey,
                ),
              ),
              if (isActive && _billing.tabs.length > 1) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _billing.removeTab(index),
                  child: const Icon(
                    LucideIcons.x,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          _cartHeaderText("ITEM DESCRIPTION", 3),
          _cartHeaderText("WGT", 1),
          _cartHeaderText("RATE", 1),
          _cartHeaderText("MAKING", 1),
          _cartHeaderText("TOTAL", 1),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _cartHeaderText(String text, int flex) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _cartItemRow(CartItem item, int index) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  "SKU: ${item.sku} | Metal Value: ₹${item.metalValue.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              "${item.weight}g",
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: Text(
              "₹${item.metalRate.toStringAsFixed(0)}",
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: Text(
              item.makingType == MakingChargeType.percentage
                  ? "${item.makingValue}%"
                  : "₹${item.makingValue.toStringAsFixed(0)}",
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: Text(
              "₹${item.total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: JewelleryTheme.gold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _billing.removeCartItem(index),
            icon: const Icon(
              LucideIcons.circleMinus,
              size: 18,
              color: JewelleryTheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String val) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formLabel(String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          letterSpacing: 1,
        ),
      ),
    );
  }
}
