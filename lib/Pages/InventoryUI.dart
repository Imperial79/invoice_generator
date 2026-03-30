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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      final items = await DatabaseService.instance.getAllInventory();
      if (mounted) {
        setState(() {
          allItems = items;
          _applyFilter();
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    if (selectedCategory == "All") {
      filteredItems = allItems;
    } else {
      filteredItems = allItems
          .where((i) => i.category == selectedCategory)
          .toList();
    }
  }

  Future<void> _handleSaveItem({
    InventoryModel? item,
    required String category,
    required String name,
    required String sku,
    required String weight,
    required String purity,
    required String charges,
    required String chargesType,
    required String stock,
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
                    weight: 0,
                    purity: "",
                    makingCharges: 0,
                    makingChargesType: "Fixed",
                    stock: 0,
                  ))
              .copyWith(
                category: category,
                name: name,
                sku: finalSku,
                weight: double.tryParse(weight) ?? 0,
                purity: purity,
                makingCharges: double.tryParse(charges) ?? 0,
                makingChargesType: chargesType,
                stock: double.tryParse(stock) ?? 0,
              );
      await DatabaseService.instance.saveInventoryItem(newItem);
      _loadData();
      KSnackbar(context, message: "Item saved successfully");
    } catch (e) {
      log("Save Item: [Error] -> $e");
      KSnackbar(context, message: "Unable to save item", error: true);
    }
  }

  Future<void> _showAddEditItemDialog([InventoryModel? item]) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: item?.name);
    final skuController = TextEditingController(text: item?.sku);
    final weightController = TextEditingController(
      text: item?.weight == 0 ? "" : item?.weight.toString(),
    );
    final purityController = TextEditingController(text: item?.purity);
    final chargesController = TextEditingController(
      text: item?.makingCharges == 0 ? "" : item?.makingCharges.toString(),
    );
    final stockController = TextEditingController(
      text: item?.stock == 0 ? "" : item?.stock.toString(),
    );
    String category = item?.category ?? "Gold";
    String chargesType = item?.makingChargesType ?? "Fixed";

    await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          constraints: const BoxConstraints(maxWidth: 700),
          title: Label(
            item == null ? "Add Inventory" : "Edit Item",
            fontSize: 20,
            weight: 700,
          ).title,
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                // SECTION: Basic Details
                _buildSectionHeader("Basic Details"),
                KDropdown<String>(
                  label: "Category",
                  value: category,
                  items: categories
                      .where((e) => e != "All")
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                KField(
                  controller: nameController,
                  label: "Item Name",
                  hintText: "e.g. Gold Ring, Silver Chain",
                  validator: KValidation.required,
                ),
                KField(
                  controller: skuController,
                  label: "Barcode / SKU",
                  hintText: "Auto-generated if left empty",
                ),

                // SECTION: Product Specs
                _buildSectionHeader("Product Specs"),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: KField(
                        controller: weightController,
                        label: "Weight (grams)",
                        hintText: "0.00",
                        keyboardType: TextInputType.number,
                        validator: KValidation.required,
                      ),
                    ),
                    if (category == "Gold")
                      Expanded(
                        child: KDropdown<String>(
                          label: "Purity",
                          value: purityController.text.isEmpty
                              ? "22K"
                              : purityController.text,
                          items: ["24K", "22K", "18K", "14K"]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setDialogState(() => purityController.text = v!),
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                ),

                // SECTION: Inventory & Pricing
                _buildSectionHeader("Inventory & Pricing"),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      flex: 2,
                      child: KField(
                        controller: chargesController,
                        label: "Making Charges",
                        hintText: "0.00",
                        keyboardType: TextInputType.number,
                        validator: KValidation.required,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: KDropdown<String>(
                        label: "Type",
                        value: chargesType,
                        items: ["Fixed", "Percent"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setDialogState(() => chargesType = v!),
                      ),
                    ),
                  ],
                ),
                KField(
                  controller: stockController,
                  label: "Initial Stock",
                  hintText: "Quantity",
                  keyboardType: TextInputType.number,
                  validator: KValidation.required,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Label(
                "Cancel",
                color: kColor(context).onSurfaceVariant,
              ).regular,
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await _handleSaveItem(
                    item: item,
                    category: category,
                    name: nameController.text,
                    sku: skuController.text,
                    weight: weightController.text,
                    purity: purityController.text.isEmpty && category == "Gold"
                        ? "22K"
                        : purityController.text,
                    charges: chargesController.text,
                    chargesType: chargesType,
                    stock: stockController.text,
                  );
                  if (context.mounted) Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kColor(context).primary,
                foregroundColor: kColor(context).onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Label("Save Item").regular,
            ),
          ],
        ),
      ),
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
      appBar: KAppBar(context, title: "Inventory Management", showBack: false),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(child: _buildInventoryList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditItemDialog(),
        icon: const Icon(LucideIcons.packagePlus),
        label: Label("Add Item").regular,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(kPadding),
      child: Row(
        spacing: 12,
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return FilterChip(
            selected: isSelected,
            label: Text(cat),
            onSelected: (v) {
              setState(() {
                selectedCategory = cat;
                _applyFilter();
              });
            },
            selectedColor: kColor(context).primaryContainer,
            labelStyle: TextStyle(
              color: isSelected
                  ? kColor(context).primary
                  : kColor(context).onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInventoryList() {
    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.package2,
              size: 60,
              color: kColor(context).outlineVariant,
            ),
            height20,
            Label(
              "No inventory items found",
              color: kColor(context).onSurfaceVariant,
            ).regular,
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Responsive.isMobile(context)
            ? ListView.separated(
                padding: const EdgeInsets.all(kPadding),
                itemCount: filteredItems.length,
                separatorBuilder: (context, index) => height15,
                itemBuilder: (context, index) =>
                    _buildItemCard(filteredItems[index]),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(kPadding),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 450,
                  mainAxisExtent: 110,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) =>
                    _buildItemCard(filteredItems[index]),
              ),
      ),
    );
  }

  Widget _buildItemCard(InventoryModel item) {
    final isLowStock = item.stock <= item.minStockAlert;

    return KCard(
      onTap: () => _showAddEditItemDialog(item),
      padding: const EdgeInsets.all(16),
      radius: 15,
      borderWidth: 1,
      borderColor: isLowStock
          ? Colors.orange.withAlpha(100)
          : kColor(context).outlineVariant,
      child: Row(
        children: [
          _buildCategoryIcon(item.category),
          width15,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Label(item.name, fontSize: 16, weight: 700).regular,
                    if (item.sku.isNotEmpty) ...[
                      width10,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kColor(context).surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Label(
                          item.sku,
                          fontSize: 10,
                          color: kColor(context).onSurfaceVariant,
                        ).regular,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Label(
                  "${item.purity} • ${item.weight}g • MC: ${item.makingChargesType == 'Percent' ? "${item.makingCharges}%" : "₹${item.makingCharges}"}",
                  fontSize: 13,
                  color: kColor(context).onSurfaceVariant,
                ).regular,
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Label(
                    item.stock.toString(),
                    fontSize: 18,
                    weight: 800,
                    color: isLowStock
                        ? Colors.orange
                        : kColor(context).onSurface,
                  ).title,
                  const SizedBox(width: 4),
                  Label(
                    "pcs",
                    fontSize: 12,
                    color: kColor(context).onSurfaceVariant,
                  ).regular,
                ],
              ),
              if (isLowStock)
                Row(
                  children: [
                    Icon(LucideIcons.info, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Label(
                      "Low Stock",
                      fontSize: 10,
                      color: Colors.orange,
                      weight: 600,
                    ).regular,
                  ],
                ),
            ],
          ),
          width15,
          const Icon(LucideIcons.chevronRight, size: 16),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    Color color = Colors.orange;
    IconData icon = LucideIcons.gem;
    if (category == "Silver") {
      color = Colors.grey;
      icon = LucideIcons.disc;
    } else if (category == "Diamond") {
      color = Colors.blue;
      icon = LucideIcons.sparkles;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
