import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../Theme.dart';
import '../Widgets/JewelleryCard.dart';
import '../Models/InventoryModel.dart';
import '../Controllers/InventoryController.dart';

class InventoryUI extends StatefulWidget {
  const InventoryUI({super.key});

  @override
  State<InventoryUI> createState() => _InventoryUIState();
}

class _InventoryUIState extends State<InventoryUI> {
  final InventoryController _controller = InventoryController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    // 🛡️ DO NOT dispose of the singleton controller!
    // Simply removing this call fixes the "Used after being disposed" error.
    super.dispose();
  }

  void _showAddItemDialog() {
    String name = "";
    String sku = "";
    String cat = "Gold";
    String purity = "22K";
    String weight = "";
    int stock = 0;

    _controller.resetValidation();

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
                    "ADD NEW INVENTORY ITEM",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Fields
                  _formLabel("Product Name", isRequired: true),
                  TextField(
                    onChanged: (v) {
                      name = v;
                      _controller.validate(name, sku, weight);
                      setDialogState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Enter full product name",
                      errorText: _controller.nameError,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _formLabel("SKU / Barcode", isRequired: true),
                  TextField(
                    onChanged: (v) {
                      sku = v;
                      _controller.validate(name, sku, weight);
                      setDialogState(() {});
                    },
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: "Enter unique SKU",
                      errorText: _controller.skuError,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _formLabel("Category", isRequired: true),
                            DropdownButtonFormField<String>(
                              value: cat,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              dropdownColor: theme.cardTheme.color,
                              items: ["Gold", "Diamond", "Silver", "Platinum"]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setDialogState(() => cat = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _formLabel("Purity / Grade", isRequired: true),
                            DropdownButtonFormField<String>(
                              initialValue: purity,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              dropdownColor: theme.cardTheme.color,
                              items: ["24K", "22K", "18K", "925", "VVS1", "SI1"]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => purity = v!,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _formLabel("Weight (g)", isRequired: true),
                            TextField(
                              onChanged: (v) {
                                weight = v;
                                _controller.validate(name, sku, weight);
                                setDialogState(() {});
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                hintText: "0.00",
                                errorText: _controller.weightError,
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
                            _formLabel("Opening Stock"),
                            TextField(
                              onChanged: (v) => stock = int.tryParse(v) ?? 0,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: "0"),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                            _controller.validate(name, sku, weight);
                            if (_controller.isValid) {
                              _controller.addItem(
                                InventoryItem(
                                  sku: sku,
                                  name: name,
                                  category: cat,
                                  purity: purity,
                                  weight: double.tryParse(weight) ?? 0.0,
                                  stock: stock,
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              setDialogState(() {});
                            }
                          },
                          child: const Text("SAVE ITEM"),
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

  Widget _formLabel(String label, {bool isRequired = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              letterSpacing: 1,
            ),
          ),
          if (isRequired)
            const Text(
              " *",
              style: TextStyle(
                color: JewelleryTheme.error,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("INVENTORY MANAGEMENT"),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showAddItemDialog(),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text("ADD ITEM"),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Stats Row
            Row(
              children: [
                _statItem(
                  "Total Items",
                  _controller.items.length.toString(),
                  LucideIcons.package,
                ),
                const SizedBox(width: 24),
                _statItem("Total Value", "₹4.2 Cr", LucideIcons.indianRupee),
                const SizedBox(width: 24),
                _statItem(
                  "Low Stock",
                  _controller.items
                      .where((e) => e.status == "Low Stock")
                      .length
                      .toString(),
                  LucideIcons.circleAlert,
                  color: JewelleryTheme.error,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Filters & Search
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search inventory...",
                      prefixIcon: Icon(
                        LucideIcons.search,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _filterButton("Category"),
                const SizedBox(width: 12),
                _filterButton("Purity"),
              ],
            ),
            const SizedBox(height: 24),

            // Inventory Table
            Expanded(
              child: JewelleryCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildTableHeader(),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _controller.items.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) =>
                            _inventoryRow(_controller.items[index]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String val, IconData icon, {Color? color}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: JewelleryCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (color ?? JewelleryTheme.gold).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color ?? JewelleryTheme.gold),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                          : JewelleryTheme.slate,
                    ),
                  ),
                  Text(
                    val,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String label) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(LucideIcons.filter, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(
          color: theme.dividerTheme.color ?? theme.colorScheme.outline,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildTableHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerColor = isDark
        ? theme.colorScheme.surface
        : theme.scaffoldBackgroundColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: headerColor,
      child: Row(
        children: [
          _headerText("ITEM NAME", 3),
          _headerText("CATEGORY", 1),
          _headerText("PURITY", 1),
          _headerText("WEIGHT", 1),
          _headerText("IN STOCK", 1),
          _headerText("STATUS", 1),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _headerText(String text, int flex) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _inventoryRow(InventoryItem item) {
    final theme = Theme.of(context);
    final stock = item.stock;
    final statusColor = stock > 5
        ? Colors.green
        : (stock > 0 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.category,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: Text(
              item.purity,
              style: TextStyle(color: theme.colorScheme.onSurface),
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
              item.stock.toString(),
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    LucideIcons.pencil,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    LucideIcons.ellipsis,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
