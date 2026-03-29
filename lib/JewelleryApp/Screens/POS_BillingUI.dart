import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import '../Theme.dart';
import '../Widgets/JewelleryCard.dart';
import '../Models/BillingModel.dart';
import '../Models/InventoryModel.dart';
import '../Controllers/BillingController.dart';
import '../Controllers/InventoryController.dart';
import '../../Essentials/kField.dart';
import '../../Essentials/kButton.dart';
import '../../Essentials/Label.dart';
import '../../Helper/pdf_helper.dart';
import '../../Models/Invoice_Model.dart';

class POSBillingUI extends StatefulWidget {
  const POSBillingUI({super.key});

  @override
  State<POSBillingUI> createState() => _POSBillingUIState();
}

class _POSBillingUIState extends State<POSBillingUI> {
  final BillingController _billing = BillingController();
  final InventoryController _inventory = InventoryController();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _metalRateCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  bool _isUpdatingFromSource = false;

  @override
  void initState() {
    super.initState();
    _updateSyncFromSource();
    _billing.addListener(_handleBillingUpdate);
    _inventory.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _metalRateCtrl.dispose();
    _searchCtrl.dispose();
    _billing.removeListener(_handleBillingUpdate);
    super.dispose();
  }

  void _handleBillingUpdate() {
    if (!mounted) return;
    if (!_isUpdatingFromSource) {
      setState(() {
        _updateSyncFromSource();
      });
    }
  }

  void _updateSyncFromSource() {
    _isUpdatingFromSource = true;
    _nameCtrl.text = _billing.currentTab.customerName;
    _phoneCtrl.text = _billing.currentTab.customerPhone;
    _metalRateCtrl.text = _billing.currentTab.defaultMetalRate.toString();
    _isUpdatingFromSource = false;
  }

  void _showAddItemToCartDialog({
    InventoryItem? preloadedItem,
    String? initialSearch,
  }) {
    String name = preloadedItem?.name ?? "";
    String sku = preloadedItem?.sku ?? "AUTO";
    double weight = preloadedItem?.weight ?? 0.0;
    double rate = _billing.currentTab.defaultMetalRate;
    MakingChargeType makingType = MakingChargeType.percentage;
    double makingValue = 12.0;

    final nameCtrl = TextEditingController(text: name);
    final skuCtrl = TextEditingController(text: sku);
    final weightCtrl = TextEditingController(
      text: weight > 0 ? weight.toString() : "",
    );
    final rateCtrl = TextEditingController(text: rate.toString());
    final makingValueCtrl = TextEditingController(text: makingValue.toString());

    List<InventoryItem> searchResults =
        (initialSearch != null && initialSearch.isNotEmpty)
        ? _inventory.searchItems(initialSearch)
        : [];

    final searchCtrl = TextEditingController(text: initialSearch)
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: initialSearch?.length ?? 0),
      );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: 550,
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Label("ADD ITEM TO CART", weight: 900, fontSize: 18).spread,
                    const SizedBox(height: 32),

                    if (preloadedItem == null) ...[
                      KField(
                        label: "Search Inventory (SKU or Name)",
                        hintText: "e.g. G-101 or Gold Ring",
                        prefix: const Icon(LucideIcons.search, size: 18),
                        controller: searchCtrl,
                        onChanged: (v) {
                          setDialogState(() {
                            searchResults = _inventory.searchItems(v);
                          });
                        },
                      ),
                      if (searchResults.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  Theme.of(context).dividerTheme.color ??
                                  Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: searchResults.length,
                            separatorBuilder: (c, i) =>
                                const Divider(height: 1),
                            itemBuilder: (c, i) {
                              final item = searchResults[i];
                              return ListTile(
                                leading: const Icon(
                                  LucideIcons.package,
                                  size: 16,
                                ),
                                title: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "SKU: ${item.sku} | Wgt: ${item.weight}g | Stock: ${item.stock}",
                                  style: const TextStyle(fontSize: 11),
                                ),
                                visualDensity: VisualDensity.compact,
                                onTap: () {
                                  setDialogState(() {
                                    name = item.name;
                                    sku = item.sku;
                                    weight = item.weight;
                                    nameCtrl.text = name;
                                    skuCtrl.text = sku;
                                    weightCtrl.text = weight.toString();
                                    searchResults = [];
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 24),
                    ],

                    KField(
                      label: "Product Name",
                      controller: nameCtrl,
                      hintText: "Enter item name",
                      onChanged: (v) => name = v,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: KField(
                            label: "Weight (g)",
                            controller: weightCtrl,
                            hintText: "0.00",
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (v) =>
                                weight = double.tryParse(v) ?? 0.0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KField(
                            label: "Metal Rate (per g)",
                            controller: rateCtrl,
                            hintText: kCurrencyFormat(5800, symbol: "₹"),
                            prefixText: "₹",
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                rate = double.tryParse(v) ?? 5800.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Label(
                      "Making Charge Type",
                      weight: 600,
                      fontSize: 13,
                    ).regular,
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 20),

                    KField(
                      label: makingType == MakingChargeType.percentage
                          ? "Making Percentage (%)"
                          : "Making Charge (Amount)",
                      controller: makingValueCtrl,
                      hintText: makingType == MakingChargeType.percentage
                          ? "12%"
                          : kCurrencyFormat(1500, symbol: "₹"),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (v) => makingValue = double.tryParse(v) ?? 0.0,
                    ),
                    const SizedBox(height: 40),

                    Row(
                      children: [
                        Expanded(
                          child: KButton(
                            onPressed: () => Navigator.pop(context),
                            label: "CANCEL",
                            style: KButtonStyle.outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KButton(
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
                            label: "ADD TO CART",
                            style: KButtonStyle.regular,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
        title: const Text("Billing"),
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
                        JewelleryCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Label(
                                "Customer Information",
                                weight: 700,
                                fontSize: 13,
                              ).regular,
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: KField(
                                      hintText: "Customer Name",
                                      prefix: const Icon(
                                        LucideIcons.user,
                                        size: 16,
                                      ),
                                      onChanged: (v) {
                                        _isUpdatingFromSource = true;
                                        _billing.updateCustomerName(v);
                                        _isUpdatingFromSource = false;
                                      },
                                      controller: _nameCtrl,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: KField(
                                      hintText: "Phone Number",
                                      prefix: const Icon(
                                        LucideIcons.phone,
                                        size: 16,
                                      ),
                                      keyboardType: TextInputType.phone,
                                      onChanged: (v) {
                                        _isUpdatingFromSource = true;
                                        _billing.updateCustomerPhone(v);
                                        _isUpdatingFromSource = false;
                                      },
                                      controller: _phoneCtrl,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: KField(
                                hintText: "Enter SKU Code to add directly...",
                                prefix: const Icon(
                                  LucideIcons.search,
                                  size: 20,
                                ),
                                textCapitalization:
                                    TextCapitalization.characters,
                                controller: _searchCtrl,
                                onFieldSubmitted: (v) {
                                  _searchCtrl.clear();
                                  final matches = _inventory.searchItems(v);
                                  if (matches.length == 1) {
                                    _showAddItemToCartDialog(
                                      preloadedItem: matches.first,
                                    );
                                  } else {
                                    _showAddItemToCartDialog(initialSearch: v);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            KButton(
                              onPressed: () => _showAddItemToCartDialog(),
                              icon: const Icon(
                                LucideIcons.circlePlus,
                                size: 18,
                              ),
                              label: "ADD ITEM",
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 15,
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

                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Label(
                          "Billing Summary",
                          weight: 800,
                          fontSize: 20,
                        ).regular,
                        height20,
                        JewelleryCard(
                          padding: const EdgeInsets.all(16),
                          color: theme.scaffoldBackgroundColor,
                          child: Column(
                            children: [
                              _priceRow(
                                "Items Count",
                                "${_billing.currentTab.cartItems.length}",
                              ),
                              _priceRow(
                                "Total Weight",
                                "${_billing.currentTab.cartItems.fold(0.0, (s, i) => s + i.weight).toStringAsFixed(3)}g",
                              ),
                              const Divider(height: 24),
                              _priceRow(
                                "Metal Value",
                                kCurrencyFormat(
                                  _billing.currentTab.totalMetal,
                                  symbol: "₹",
                                ),
                              ),
                              _priceRow(
                                "Making Charges",
                                kCurrencyFormat(
                                  _billing.currentTab.totalMaking,
                                  symbol: "₹",
                                ),
                              ),
                              _priceRow(
                                "Subtotal",
                                kCurrencyFormat(
                                  _billing.currentTab.subTotal,
                                  symbol: "₹",
                                ),
                              ),
                              _priceRow(
                                "GST (3%)",
                                kCurrencyFormat(
                                  _billing.currentTab.tax,
                                  symbol: "₹",
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        KField(
                          label: "TODAY'S METAL RATE",
                          prefixText: "₹",
                          keyboardType: TextInputType.number,
                          controller: _metalRateCtrl,
                          onChanged: (v) {
                            double? val = double.tryParse(v);
                            if (val != null) {
                              _isUpdatingFromSource = true;
                              _billing.updateDefaultMetalRate(val);
                              _isUpdatingFromSource = false;
                            }
                          },
                        ),
                        height20,
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: JewelleryTheme.gold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: JewelleryTheme.gold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Label(
                                    "Grand Total",
                                    weight: 600,
                                    fontSize: 14,
                                  ).regular,
                                  Label(
                                    kCurrencyFormat(
                                      _billing.currentTab.grandTotal,
                                      symbol: "₹",
                                    ),
                                    weight: 900,
                                    fontSize: 24,
                                    color: JewelleryTheme.gold,
                                  ).regular,
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        KButton(
                          onPressed: () async {
                            if (_billing.currentTab.cartItems.isNotEmpty) {
                              final invoice = await _billing
                                  .completeCurrentBill(_inventory);
                              if (invoice != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Bill successfully generated & stock adjusted!",
                                    ),
                                  ),
                                );
                                // Automatically open PDF preview
                                await PdfHelper.generateInvoice(invoice);
                              }
                            }
                          },
                          label: "GENERATE INVOICE",
                          style: KButtonStyle.expanded,
                          backgroundColor: JewelleryTheme.gold,
                          icon: const Icon(LucideIcons.fileCheck2, size: 20),
                        ),
                        const SizedBox(height: 12),
                        KButton(
                          onPressed: () {},
                          label: "PRINT ESTIMATE",
                          style: KButtonStyle.expanded,
                          backgroundColor: isDark
                              ? Colors.white10
                              : Colors.black87,
                          icon: const Icon(LucideIcons.printer, size: 18),
                        ),
                      ],
                    ),
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerTheme.color ?? theme.colorScheme.outline,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
      decoration: BoxDecoration(
        borderRadius: .vertical(top: Radius.circular(15)),
        color: theme.scaffoldBackgroundColor,
      ),
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
                  "SKU: ${item.sku} | Metal Value: ${kCurrencyFormat(item.metalValue, symbol: "₹")}",
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
              kCurrencyFormat(item.metalRate, symbol: "₹"),
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: Text(
              item.makingType == MakingChargeType.percentage
                  ? "${item.makingValue}%"
                  : kCurrencyFormat(item.makingValue, symbol: "₹"),
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: Text(
              kCurrencyFormat(item.total, symbol: "₹"),
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
}
