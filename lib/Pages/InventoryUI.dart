import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Models/Inventory_Model.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Essentials/KField.dart';
import 'package:prime_invoice/Essentials/KDropdown.dart';
import 'package:prime_invoice/Helper/responsive.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class InventoryUI extends StatefulWidget {
  const InventoryUI({super.key});

  @override
  State<InventoryUI> createState() => _InventoryUIState();
}

class _InventoryUIState extends State<InventoryUI> {
  List<InventoryModel> allItems = [];
  List<InventoryModel> filteredItems = [];
  String selectedCategory = "All";
  final List<String> categories = ["All", "Gold", "Silver", "Diamond"];
  final isLoading = ValueNotifier(false);

  int currentPage = 0;
  final int itemsPerPage = 8;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    allItems = await DatabaseService.instance.getAllInventory();
    _applyFilter();
    isLoading.value = false;
  }

  void _applyFilter() {
    setState(() {
      filteredItems = allItems.where((item) {
        final matchesCategory =
            selectedCategory == "All" || item.category == selectedCategory;
        final matchesSearch = item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            item.sku.toLowerCase().contains(searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
      currentPage = 0; // Reset to first page on filter
    });
  }

  Future<void> _handleDeleteItem(InventoryModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Label("Delete Item", weight: 700).title,
        content: Label("Are you sure you want to delete ${item.name}? This action cannot be undone.").regular,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: kColor(context).error),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.instance.deleteInventoryItem(item.id!);
      _loadData();
      KSnackbar(context, message: "Item deleted successfully");
    }
  }

  Future<void> _handleSaveItem({
    InventoryModel? item,
    required String category,
    required String name,
    required String sku,
    required String weightStock,
    required String purity,
    required String charges,
    required String chargesType,
    required String pieceStock,
  }) async {
    try {
      String finalSku = sku.trim();
      if (finalSku.isEmpty) {
        final datePart = DateTime.now().millisecondsSinceEpoch
            .toString()
            .substring(7);
        finalSku = "${category.substring(0, 1).toUpperCase()}$datePart";
      }

      final newItem =
          (item ??
                  InventoryModel(
                    name: "",
                    category: "Gold",
                    weightStock: 0,
                    purity: "",
                    makingCharges: 0,
                    makingChargesType: "Fixed",
                    pieceStock: 0,
                  ))
              .copyWith(
                category: category,
                name: name,
                sku: finalSku,
                weightStock: double.tryParse(weightStock) ?? 0,
                purity: purity,
                makingCharges: double.tryParse(charges) ?? 0,
                makingChargesType: chargesType,
                pieceStock: double.tryParse(pieceStock) ?? 0,
              );
      await DatabaseService.instance.saveInventoryItem(newItem);
      _loadData();
      KSnackbar(context, message: "Item saved successfully");
    } catch (e) {
      log("Save Item: [Error] -> $e");
      KSnackbar(context, message: "Unable to save item", error: true);
    }
  }

  Future<void> _showAddEditItemSidebar([InventoryModel? item]) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: item?.name);
    final skuController = TextEditingController(text: item?.sku);
    final weightController = TextEditingController(
      text: item?.weightStock == 0 ? "" : item?.weightStock.toString(),
    );
    final purityController = TextEditingController(text: item?.purity);
    final chargesController = TextEditingController(
      text: item?.makingCharges == 0 ? "" : item?.makingCharges.toString(),
    );
    final stockController = TextEditingController(
      text: item?.pieceStock == 0 ? "" : item?.pieceStock.toString(),
    );
    String category = item?.category ?? "Gold";
    String chargesType = item?.makingChargesType ?? "Fixed";

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width > 600 ? 550 : MediaQuery.of(context).size.width * 0.95,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: kColor(context).surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 30,
                      offset: const Offset(-5, 0),
                    ),
                  ],
                ),
                child: StatefulBuilder(
                  builder: (context, setSidebarState) => Column(
                    children: [
                      // Sidebar Header
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: kColor(context).outlineVariant.withAlpha(50),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kColor(context).primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                item == null ? LucideIcons.packagePlus : LucideIcons.packageCheck,
                                color: kColor(context).primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Label(
                                    item == null ? "Add Inventory" : "Modify Inventory Item",
                                    fontSize: 22,
                                    weight: 800,
                                  ).title,
                                  Label(
                                    item == null ? "Create a new entry in your stock" : "Update the current item specifications",
                                    fontSize: 12,
                                    color: kColor(context).onSurfaceVariant,
                                  ).regular,
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(LucideIcons.x),
                            ),
                          ],
                        ),
                      ),

                      // Sidebar Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. PRODUCT IDENTITY
                                _buildSectionHeader("PRODUCT IDENTITY"),
                                const SizedBox(height: 20),
                                Center(
                                  child: SegmentedButton<String>(
                                    segments: categories
                                        .where((c) => c != "All")
                                        .map(
                                          (c) => ButtonSegment(
                                            value: c,
                                            label: Text(c),
                                            icon: Icon(
                                              c == "Gold"
                                                  ? LucideIcons.gem
                                                  : c == "Silver"
                                                      ? LucideIcons.disc
                                                      : LucideIcons.sparkles,
                                              size: 16,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    selected: {category},
                                    onSelectionChanged: (val) {
                                      setSidebarState(() => category = val.first);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),
                                KField(
                                  controller: nameController,
                                  label: "Item Name",
                                  hintText: "e.g. Traditional Gold Bangle",
                                  validator: KValidation.required,
                                  prefix: const Icon(LucideIcons.tag, size: 18),
                                ),
                                const SizedBox(height: 24),
                                KField(
                                  controller: skuController,
                                  label: "SKU / Barcode",
                                  hintText: "System will generate if left blank",
                                  prefix: const Icon(LucideIcons.barcode, size: 18),
                                ),
                                const SizedBox(height: 40),

                                // 2. INVENTORY BALANCE
                                _buildSectionHeader("INVENTORY BALANCE"),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: KField(
                                        controller: weightController,
                                        label: "Total Weight stock (Gms)",
                                        hintText: "0.000",
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        validator: KValidation.required,
                                        prefix: const Icon(LucideIcons.scale, size: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: KField(
                                        controller: stockController,
                                        label: "Total Pieces stock",
                                        hintText: "0",
                                        keyboardType: TextInputType.number,
                                        validator: KValidation.required,
                                        prefix: const Icon(LucideIcons.layers, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),

                                // 3. PRODUCT SPECIFICATIONS
                                if (category == "Gold") ...[
                                  _buildSectionHeader("PRODUCT SPECIFICATIONS"),
                                  const SizedBox(height: 20),
                                  KDropdown<String>(
                                    label: "Gold Purity",
                                    value: purityController.text.isEmpty ? "22K" : purityController.text,
                                    items: ["24K", "22K", "18K", "14K"]
                                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (v) => setSidebarState(() => purityController.text = v!),
                                  ),
                                  const SizedBox(height: 40),
                                ],

                                // 4. DEFAULT PRICING
                                _buildSectionHeader("DEFAULT PRICING"),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: KField(
                                        controller: chargesController,
                                        label: "Making Charges",
                                        hintText: "0.00",
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        validator: KValidation.required,
                                        prefix: const Icon(LucideIcons.hammer, size: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 1,
                                      child: KDropdown<String>(
                                        label: "Basis",
                                        value: chargesType,
                                        items: ["Fixed", "Percent"]
                                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                            .toList(),
                                        onChanged: (v) => setSidebarState(() => chargesType = v!),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Sidebar Footer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        decoration: BoxDecoration(
                          color: kColor(context).surfaceContainerLow,
                          border: Border(
                            top: BorderSide(
                              color: kColor(context).outlineVariant.withAlpha(50),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Label("Discard Changes", weight: 700).regular,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    await _handleSaveItem(
                                      item: item,
                                      category: category,
                                      name: nameController.text,
                                      sku: skuController.text,
                                      weightStock: weightController.text,
                                      purity: purityController.text.isEmpty && category == "Gold" ? "22K" : purityController.text,
                                      charges: chargesController.text,
                                      chargesType: chargesType,
                                      pieceStock: stockController.text,
                                    );
                                    if (context.mounted) Navigator.pop(context, true);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kColor(context).primary,
                                  foregroundColor: kColor(context).onPrimary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Label("Save Inventory Item", weight: 700).regular,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label(
          title,
          fontSize: 14,
          weight: 700,
          color: kColor(context).primary,
        ).regular,
        const SizedBox(height: 4),
        Divider(
          color: kColor(context).outlineVariant.withAlpha(100),
          thickness: 1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(context, title: "Inventory Master", showBack: false),
      body: Column(
        children: [
          _buildFilterHeader(),
          Expanded(child: _buildMainContent()),
          if (filteredItems.isNotEmpty && !Responsive.isMobile(context)) _buildPaginationFooter(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditItemSidebar(),
        icon: const Icon(LucideIcons.packagePlus),
        elevation: 4,
        backgroundColor: kColor(context).primary,
        foregroundColor: kColor(context).onPrimary,
        label: Label("Add New Item", weight: 700).regular,
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      decoration: BoxDecoration(
        color: kColor(context).surface,
        border: Border(bottom: BorderSide(color: kColor(context).outlineVariant.withAlpha(50))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: KField(
                      controller: searchController,
                      hintText: "Search by item name or SKU...",
                      prefix: const Icon(LucideIcons.search, size: 18),
                      onChanged: (v) {
                        searchQuery = v;
                        _applyFilter();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildCategorySelector(),
                ],
              ),
              if (searchQuery.isNotEmpty || selectedCategory != "All")
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Label("Filters: ", fontSize: 12, weight: 600, color: kColor(context).onSurfaceVariant).regular,
                      if (selectedCategory != "All")
                        _buildFilterTag(selectedCategory, () {
                          setState(() {
                            selectedCategory = "All";
                            _applyFilter();
                          });
                        }),
                      if (searchQuery.isNotEmpty)
                        _buildFilterTag("Search: $searchQuery", () {
                          setState(() {
                            searchController.clear();
                            searchQuery = "";
                            _applyFilter();
                          });
                        }),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: kColor(context).surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kColor(context).outlineVariant.withAlpha(80)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          items: categories.map((e) => DropdownMenuItem(value: e, child: Label(e).regular)).toList(),
          onChanged: (v) {
            setState(() {
              selectedCategory = v!;
              _applyFilter();
            });
          },
        ),
      ),
    );
  }

  Widget _buildFilterTag(String label, VoidCallback onClear) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kColor(context).primary.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kColor(context).primary.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Label(label, fontSize: 11, weight: 700, color: kColor(context).primary).regular,
          const SizedBox(width: 4),
          InkWell(
            onTap: onClear,
            child: Icon(LucideIcons.x, size: 12, color: kColor(context).primary),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.packageX, size: 64, color: kColor(context).outlineVariant),
            const SizedBox(height: 16),
            Label("No Inventory Items Found", weight: 700).title,
            Label("Try adjusting your search or filters", color: kColor(context).onSurfaceVariant).regular,
          ],
        ),
      );
    }

    if (Responsive.isMobile(context)) {
      return ListView.separated(
        padding: const EdgeInsets.all(kPadding),
        itemCount: filteredItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildItemCard(filteredItems[index]),
      );
    }

    // Paginated Table for Desktop/Tablet
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage) > filteredItems.length
        ? filteredItems.length
        : startIndex + itemsPerPage;
    final pageItems = filteredItems.sublist(startIndex, endIndex);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(kPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: KCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: DataTable(
                headingRowHeight: 60,
                dataRowMinHeight: 75,
                dataRowMaxHeight: 75,
                headingRowColor: WidgetStateProperty.all(kColor(context).surfaceContainerHigh),
                columns: [
                  DataColumn(label: Label("SL", weight: 800).regular),
                  DataColumn(label: Label("PRODUCT DETAILS", weight: 800).regular),
                  DataColumn(label: Label("METAL SPECS", weight: 800).regular),
                  DataColumn(label: Label("PIECE STOCK", weight: 800).regular),
                  DataColumn(label: Label("WEIGHT STOCK", weight: 800).regular),
                  DataColumn(label: Label("PRICING (MC)", weight: 800).regular),
                  DataColumn(label: Label("ACTIONS", weight: 800).regular),
                ],
                rows: pageItems.map((item) {
                  final index = filteredItems.indexOf(item) + 1;
                  final isLowStock = item.pieceStock <= item.minStockAlert;
                  
                  return DataRow(
                    cells: [
                      DataCell(Label(index.toString().padLeft(2, '0')).regular),
                      DataCell(
                        Row(
                          children: [
                            _buildMiniCategoryIcon(item.category),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Label(item.name, weight: 700).regular,
                                _buildSkuChip(item.sku),
                              ],
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Label(item.category, fontSize: 12, weight: 600).regular,
                            if (item.category == "Gold")
                              Label(item.purity, fontSize: 10, color: kColor(context).onSurfaceVariant).regular,
                          ],
                        ),
                      ),
                      DataCell(_buildStockBadge(item.pieceStock, isLowStock, "PCS")),
                      DataCell(_buildStockBadge(item.weightStock, item.weightStock <= 5, "GMS")), // Arbitrary 5g alert
                      DataCell(
                        Label(
                          item.makingChargesType == "Percent"
                              ? "${item.makingCharges}%"
                              : "₹${item.makingCharges}",
                          weight: 600,
                          color: kColor(context).primary,
                        ).regular,
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _showAddEditItemSidebar(item),
                              icon: const Icon(LucideIcons.pencil, size: 18),
                              tooltip: "Edit",
                              color: kColor(context).primary,
                            ),
                            IconButton(
                              onPressed: () => _handleDeleteItem(item),
                              icon: const Icon(LucideIcons.trash2, size: 18),
                              tooltip: "Delete",
                              color: kColor(context).error,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationFooter() {
    final totalPages = (filteredItems.length / itemsPerPage).ceil();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kPadding, vertical: 16),
      decoration: BoxDecoration(
        color: kColor(context).surface,
        border: Border(top: BorderSide(color: kColor(context).outlineVariant.withAlpha(50))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Label("Showing ${currentPage * itemsPerPage + 1} to ${((currentPage + 1) * itemsPerPage).clamp(0, filteredItems.length)} of ${filteredItems.length} entries", fontSize: 12).regular,
          Row(
            children: [
              IconButton(
                onPressed: currentPage > 0 ? () => setState(() => currentPage--) : null,
                icon: const Icon(LucideIcons.chevronLeft),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: kColor(context).primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Label("Page ${currentPage + 1} of $totalPages", weight: 700, color: kColor(context).primary).regular,
              ),
              IconButton(
                onPressed: (currentPage + 1) < totalPages ? () => setState(() => currentPage++) : null,
                icon: const Icon(LucideIcons.chevronRight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(double value, bool isLow, String unit) {
    final color = isLow ? Colors.orange : kColor(context).onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isLow ? Colors.orange.withAlpha(20) : kColor(context).surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isLow ? Colors.orange.withAlpha(50) : kColor(context).outlineVariant.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Label(
            unit == "PCS" ? value.toInt().toString() : value.toStringAsFixed(3),
            weight: 900,
            color: isLow ? Colors.orange : null,
          ).regular,
          const SizedBox(width: 4),
          Label(unit, fontSize: 8, weight: 800, color: color.withAlpha(150)).regular,
        ],
      ),
    );
  }

  Widget _buildMiniCategoryIcon(String category) {
    Color color = Colors.orange;
    if (category == "Silver") color = Colors.grey;
    if (category == "Diamond") color = Colors.blue;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        category == "Gold" ? LucideIcons.gem : category == "Silver" ? LucideIcons.disc : LucideIcons.sparkles,
        color: color,
        size: 18,
      ),
    );
  }

  Widget _buildItemCard(InventoryModel item) {
    final isLowStock = item.pieceStock <= item.minStockAlert;
    return KCard(
      onTap: () => _showAddEditItemSidebar(item),
      padding: const EdgeInsets.all(18),
      color: isLowStock
          ? Colors.orange.withAlpha(10)
          : kColor(context).surfaceContainerLow,
      child: Row(
        children: [
          _buildCategoryIcon(item.category),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Label(
                        item.name,
                        fontSize: 16,
                        weight: 700,
                        maxLines: 1,
                      ).title,
                    ),
                    if (item.sku.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      _buildSkuChip(item.sku),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSpecTag(LucideIcons.scale, "${item.weightStock.toStringAsFixed(3)} Gms"),
                    if (item.purity.isNotEmpty) _buildSpecTag(LucideIcons.award, item.purity),
                    _buildSpecTag(
                      LucideIcons.hammer,
                      item.makingChargesType == 'Percent'
                          ? "${item.makingCharges}% MC"
                          : "Rs.${item.makingCharges} MC",
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildStockIndicator(item.pieceStock, isLowStock),
        ],
      ),
    );
  }

  Widget _buildSkuChip(String sku) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kColor(context).primary.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kColor(context).primary.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.barcode, size: 10, color: kColor(context).primary),
          const SizedBox(width: 4),
          Label(
            sku,
            fontSize: 9,
            weight: 800,
            color: kColor(context).primary,
          ).regular,
        ],
      ),
    );
  }

  Widget _buildStockIndicator(double stock, bool isLowStock) {
    final color = isLowStock ? Colors.orange : kColor(context).primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Label(
            stock.toInt().toString(),
            fontSize: 20,
            weight: 900,
            color: color,
          ).title,
          Label(
            "PCS STOCK",
            fontSize: 8,
            weight: 800,
            color: color,
          ).regular,
        ],
      ),
    );
  }

  Widget _buildSpecTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: kColor(context).surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: kColor(context).outlineVariant.withAlpha(100),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: kColor(context).onSurfaceVariant),
          const SizedBox(width: 4),
          Label(
            text,
            fontSize: 11,
            color: kColor(context).onSurfaceVariant,
            weight: 600,
          ).regular,
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    Color color = Colors.orange;
    Color bgColor = Colors.orange.withAlpha(25);
    IconData icon = LucideIcons.gem;
    if (category == "Silver") {
      color = Colors.grey.shade600;
      bgColor = Colors.grey.withAlpha(25);
      icon = LucideIcons.disc;
    } else if (category == "Diamond") {
      color = Colors.blue;
      bgColor = Colors.blue.withAlpha(25);
      icon = LucideIcons.sparkles;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(50), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
