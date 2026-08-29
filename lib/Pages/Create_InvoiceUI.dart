import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kButton.dart';
import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Essentials/kField.dart';
import 'package:prime_invoice/Helper/date_helper.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Helper/pdf_helper.dart';
import 'package:prime_invoice/Models/Customer_Model.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:prime_invoice/Models/Item_Model.dart';
import 'package:prime_invoice/Models/Inventory_Model.dart';
import 'package:prime_invoice/Models/Metal_Rate_Model.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prime_invoice/Helper/responsive.dart';
import 'package:prime_invoice/Essentials/KTable.dart';

class CreateInvoiceUI extends StatefulWidget {
  final InvoiceModel? invoice;
  const CreateInvoiceUI({super.key, this.invoice});

  @override
  State<CreateInvoiceUI> createState() => _CreateInvoiceUIState();
}

class _CreateInvoiceUIState extends State<CreateInvoiceUI> {
  DateTime invoiceDate = DateTime.now();
  final _customerFormKey = GlobalKey<FormState>();
  final tax = TextEditingController();
  final gst = TextEditingController();
  double metalGstRate = 3.0;
  double serviceGstRate = 18.0;

  List<ItemModel> addedItems = [];
  final invoiceNo = TextEditingController();
  final itemName = TextEditingController();
  final skuController = TextEditingController();
  final qty = TextEditingController();
  String unit = "Gms";
  final price = TextEditingController();
  double amount = 0;
  final billingAddress = TextEditingController();

  bool forCustomer = true;
  final customerName = TextEditingController();
  final customerPhone = TextEditingController();
  final customerPan = TextEditingController();
  final customerGst = TextEditingController();
  final customerAadhaar = TextEditingController();
  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadProfile();
    invoiceDate = widget.invoice?.invoiceDate ?? DateTime.now();

    if (widget.invoice != null) {
      final inv = widget.invoice!;
      invoiceNo.text = inv.invoiceId;
      customerName.text = inv.customerName;
      customerPhone.text = inv.customerPhone;
      customerPan.text = inv.customerPan;
      customerGst.text = inv.customerGst;
      customerAadhaar.text = inv.customerAadhaar;
      billingAddress.text = inv.billingAddress;
      addedItems = List.from(inv.items);
      forCustomer = inv.forCustomer;
    } else {
      invoiceNo.text =
          "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    }
    _loadGstSettings();
  }

  Future<void> _loadGstSettings() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      metalGstRate = pref.getDouble("metal_gst") ?? 3.0;
      serviceGstRate = pref.getDouble("service_gst") ?? 18.0;
    });
  }

  Future<void> _loadProfile() async {
    final pref = await SharedPreferences.getInstance();
    final bAddress = pref.getString("biz_address");
    if (bAddress != null && widget.invoice == null) {
      setState(() => billingAddress.text = bAddress);
    }
  }

  Future<void> createInvoice() async {
    try {
      if (!_customerFormKey.currentState!.validate()) {
        KSnackbar(
          context,
          message: "Please fill in all required details",
          error: true,
        );
        return;
      }
      if (addedItems.isEmpty) {
        KSnackbar(
          context,
          message: "Please add at least one item",
          error: true,
        );
        return;
      }

      isLoading.value = true;
      double total = 0;
      for (ItemModel item in addedItems) {
        total += item.amount + (item.amount * item.gst / 100);
      }

      InvoiceModel invoiceData = InvoiceModel(
        invoiceId: invoiceNo.text,
        items: addedItems,
        forCustomer: forCustomer,
        customerName: customerName.text,
        customerPhone: customerPhone.text,
        customerAadhaar: customerAadhaar.text,
        customerPan: customerPan.text,
        customerGst: customerGst.text,
        billingAddress: billingAddress.text,
        grandTotal: total,
        invoiceDate: invoiceDate,
      );

      // Auto-save/Update client
      if (customerName.text.isNotEmpty && customerPhone.text.length == 10) {
        final existing = await DatabaseService.instance.getCustomerByPhone(
          customerPhone.text,
        );
        final customer = CustomerModel(
          id: existing?.id,
          name: customerName.text,
          phone: customerPhone.text,
          address: billingAddress.text,
          gst: customerGst.text,
          pan: customerPan.text,
          aadhaar: customerAadhaar.text,
          clientType: forCustomer ? "Customer" : "Business",
        );
        await DatabaseService.instance.saveCustomer(customer);
      }

      await PdfHelper.generateInvoice(invoiceData);
      await DatabaseService.instance.saveInvoice(invoiceData);

      // Deduct Stock and record logs
      final allInventory = await DatabaseService.instance.getAllInventory();
      for (var item in addedItems) {
        final invItem = allInventory.firstWhere(
          (inv) => inv.sku == item.sku,
          orElse: () =>
              allInventory.firstWhere((inv) => inv.name == item.itemName),
        );

        if (invItem.id != null) {
          await DatabaseService.instance.recordStockAdjustment(
            item: invItem,
            weightDelta: -item.weight,
            pieceDelta: -item.qty,
            action: 'Debit',
            type: 'Sale',
            notes: 'Invoice Generated: ${invoiceData.invoiceId}',
          );
        }
      }

      if (mounted) {
        KSnackbar(
          context,
          message: "Invoice generated and saved successfully!",
        );
      }
    } catch (e) {
      KSnackbar(context, message: e.toString(), error: true);
    } finally {
      isLoading.value = false;
    }
  }

  void clearFields() {
    itemName.clear();
    skuController.clear();
    qty.clear();
    price.clear();
    gst.clear();
  }

  @override
  void dispose() {
    invoiceNo.dispose();
    itemName.dispose();
    skuController.dispose();
    qty.dispose();
    price.dispose();
    tax.dispose();
    gst.dispose();
    billingAddress.dispose();
    customerName.dispose();
    customerPhone.dispose();
    customerPan.dispose();
    customerGst.dispose();
    customerAadhaar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(
        context,
        title: "Create Invoice",
        showBack: false,
        actions: [
          IconButton(
            onPressed: () async {
              final data = await DateHelper.pickDate(
                context,
                currentDate: invoiceDate,
              );
              if (data != null) setState(() => invoiceDate = data);
            },
            icon: const Icon(LucideIcons.calendar),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
                  if (Responsive.isMobile(context)) ...[
                    _buildSectionHeader(
                      "Invoice Details",
                      LucideIcons.fileText,
                    ),
                    _buildInvoiceInfo(),
                    _buildSectionHeader("Party Details", LucideIcons.user),
                    _buildPartyDetails(),
                    _buildSectionHeader("Items List", LucideIcons.package),
                    _buildItemsSection(),
                    _buildSummarySection(),
                    _buildSectionHeader("Other Details", LucideIcons.ellipsis),
                    _buildOtherDetails(),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 32,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 24,
                            children: [
                              _buildSectionHeader(
                                "Items List",
                                LucideIcons.package,
                              ),
                              _buildItemsSection(),
                              _buildSummarySection(),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 24,
                            children: [
                              _buildSectionHeader(
                                "Invoice Details",
                                LucideIcons.fileText,
                              ),
                              _buildInvoiceInfo(),
                              _buildSectionHeader(
                                "Party Details",
                                LucideIcons.user,
                              ),
                              _buildPartyDetails(),
                              _buildSectionHeader(
                                "Other Details",
                                LucideIcons.ellipsis,
                              ),
                              _buildOtherDetails(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createInvoice,
        icon: const Icon(LucideIcons.fileOutput),
        backgroundColor: kColor(context).primary,
        foregroundColor: Colors.white,
        label: Label("Generate Invoice", weight: 700).regular,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      spacing: 12,
      children: [
        Icon(icon, size: 20, color: kColor(context).primary),
        Label(title, fontSize: 18, weight: 800).title,
      ],
    );
  }

  Widget _buildInvoiceInfo() {
    return KCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        spacing: 16,
        children: [
          KField(
            controller: invoiceNo,
            label: "Invoice No.",
            prefix: const Icon(LucideIcons.hash, size: 16),
            suffix: IconButton(
              onPressed: () => setState(
                () => invoiceNo.text =
                    "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
              ),
              icon: const Icon(LucideIcons.refreshCw, size: 14),
            ),
          ),
          KField(
            readOnly: true,
            label: "Date",
            hintText: kDateFormat(invoiceDate.toString()),
            prefix: const Icon(LucideIcons.calendar, size: 16),
            onTap: () async {
              final data = await DateHelper.pickDate(
                context,
                currentDate: invoiceDate,
              );
              if (data != null) setState(() => invoiceDate = data);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPartyDetails() {
    return KCard(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _customerFormKey,
        child: Column(
          spacing: 20,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Label(
                  forCustomer ? "Customer Details" : "Business Details",
                  weight: 700,
                ).title,
                Switch.adaptive(
                  value: forCustomer,
                  onChanged: (v) => setState(() => forCustomer = v),
                ),
              ],
            ),
            const Divider(),
            KField(
              controller: customerName,
              label: "Name",
              prefix: const Icon(LucideIcons.user, size: 16),
              suffix: IconButton(
                onPressed: _showExistingClients,
                icon: const Icon(
                  LucideIcons.users,
                  size: 18,
                  color: Colors.blue,
                ),
              ),
              validator: (v) => KValidation.required(v),
            ),
            KField(
              controller: customerPhone,
              label: "Phone",
              prefix: const Icon(LucideIcons.phone, size: 16),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (v) => KValidation.phone(v),
            ),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: KField(
                    controller: customerPan,
                    label: "PAN",
                    showRequired: false,
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                Expanded(
                  child: KField(
                    controller: customerAadhaar,
                    label: "Aadhaar",
                    showRequired: false,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            KField(
              controller: customerGst,
              label: "GSTIN",
              showRequired: false,
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      spacing: 16,
      children: [
        if (addedItems.isEmpty)
          _emptyItemsPlaceholder()
        else
          KTable(
            showCheckboxColumn: false,
            columns: [
              KTableColumn(label: Label("Sl.", weight: 700).regular),
              KTableColumn(label: Label("Description", weight: 700).regular),
              KTableColumn(label: Label("Weight", weight: 700).regular),
              KTableColumn(label: Label("Qty", weight: 700).regular),
              KTableColumn(label: Label("Total Price", weight: 700).regular),
              KTableColumn(label: Label("Actions", weight: 700).regular),
            ],
            rows: addedItems.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final item = entry.value;
              return KTableRow(
                cells: [
                  Label("$idx").regular,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Label(item.itemName, weight: 600).regular,
                      Label(
                        item.sku,
                        fontSize: 10,
                        color: kColor(context).onSurfaceVariant,
                      ).regular,
                    ],
                  ),
                  Label("${item.weight.toStringAsFixed(3)}g").regular,
                  Label("${item.qty.toInt()} Pcs").regular,
                  Label(
                    "Rs.${item.amount.toStringAsFixed(2)}",
                    weight: 800,
                    color: kColor(context).primary,
                  ).regular,
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showAddItemSidebar(
                          id: item.id,
                          existingItem: item,
                        ),
                        icon: Icon(
                          LucideIcons.pencil,
                          size: 16,
                          color: kColor(context).primary,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => addedItems.remove(item)),
                        icon: const Icon(
                          LucideIcons.trash2,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        KButton(
          onPressed: () => _showAddItemSidebar(id: addedItems.length + 1),
          label: "Add New Item",
          icon: const Icon(LucideIcons.plus),
          style: KButtonStyle.expanded,
        ),
      ],
    );
  }

  Widget _emptyItemsPlaceholder() {
    return KCard(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      color: kColor(context).surfaceContainerLowest,
      child: Column(
        spacing: 12,
        children: [
          Icon(
            LucideIcons.clipboardList,
            size: 48,
            color: kColor(context).outline,
          ),
          Label(
            "No items added yet",
            color: kColor(context).onSurfaceVariant,
          ).regular,
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    if (addedItems.isEmpty) return const SizedBox.shrink();
    double subTotal = addedItems.fold(0, (s, i) => s + i.amount);
    double totalGst = addedItems.fold(
      0,
      (s, i) => s + (i.amount * i.gst / 100),
    );
    return KCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        spacing: 12,
        children: [
          _summaryRow("Sub Total", "Rs.${subTotal.toStringAsFixed(2)}"),
          _summaryRow("Tax Amount", "Rs.${totalGst.toStringAsFixed(2)}"),
          const Divider(),
          _summaryRow(
            "Net Payable",
            "Rs.${(subTotal + totalGst).round().toStringAsFixed(2)}",
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Label(
          label,
          fontSize: isBold ? 16 : 14,
          weight: isBold ? 800 : 400,
        ).regular,
        Label(
          val,
          fontSize: isBold ? 20 : 14,
          weight: isBold ? 900 : 700,
          color: isBold ? kColor(context).primary : null,
        ).regular,
      ],
    );
  }

  Widget _buildOtherDetails() {
    return KCard(
      padding: const EdgeInsets.all(20),
      child: KField(
        controller: billingAddress,
        label: "Billing Address",
        maxLines: 3,
        validator: (v) => KValidation.required(v),
      ),
    );
  }

  void _showExistingClients() async {
    isLoading.value = true;
    final customers = await DatabaseService.instance.getAllCustomers();
    isLoading.value = false;
    if (customers.isEmpty) {
      if (mounted) {
        KSnackbar(context, message: "No clients found!", error: true);
      }
      return;
    }

    String q = "";
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (c, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (c, a1, a2, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: a1, curve: Curves.easeOutCubic)),
        child: Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: Container(
              width: Responsive.isMobile(context)
                  ? MediaQuery.sizeOf(context).width
                  : 500,
              height: double.infinity,
              color: kColor(context).surface,
              child: StatefulBuilder(
                builder: (cSelf, setSidebarState) {
                  final res = customers
                      .where(
                        (cu) =>
                            cu.name.toLowerCase().contains(q.toLowerCase()) ||
                            cu.phone.contains(q),
                      )
                      .toList();
                  return Column(
                    children: [
                      _sidebarHeader("Select Client", LucideIcons.users, cSelf),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: KField(
                          hintText: "Search name...",
                          onChanged: (v) => setSidebarState(() => q = v),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: res.length,
                          separatorBuilder: (c, i) => const Divider(),
                          itemBuilder: (c, i) => ListTile(
                            leading: CircleAvatar(
                              child: Label(res[i].name[0]).title,
                            ),
                            title: Label(res[i].name, weight: 600).regular,
                            subtitle: Label(res[i].phone).regular,
                            onTap: () {
                              setState(() {
                                customerName.text = res[i].name;
                                customerPhone.text = res[i].phone;
                                customerPan.text = res[i].pan;
                                customerGst.text = res[i].gst;
                                customerAadhaar.text = res[i].aadhaar;
                                billingAddress.text = res[i].address;
                              });
                              Navigator.pop(cSelf);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddItemSidebar({required int id, ItemModel? existingItem}) {
    InventoryModel? sel;
    List<InventoryModel> all = [];
    String qSearch =
        ""; // Renamed from q to qSearch to avoid potential shadowing
    final weightC = TextEditingController(
      text: existingItem?.weight.toStringAsFixed(3) ?? "",
    );
    final qtyC = TextEditingController(
      text: existingItem?.qty.toInt().toString() ?? "1",
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (c, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (c, a1, a2, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: a1, curve: Curves.easeOutCubic)),
        child: Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: Container(
              width: Responsive.isMobile(context)
                  ? MediaQuery.sizeOf(context).width
                  : 600,
              height: double.infinity,
              color: kColor(context).surface,
              child: StatefulBuilder(
                builder: (c, setState) {
                  return FutureBuilder<List<InventoryModel>>(
                    future: all.isEmpty
                        ? DatabaseService.instance.getAllInventory()
                        : Future.value(all),
                    builder: (context, snap) {
                      if (snap.hasData && all.isEmpty) {
                        all = snap.data!;
                        if (existingItem != null) {
                          sel = all.firstWhere(
                            (it) => it.sku == existingItem.sku,
                            orElse: () => all.firstWhere(
                              (it) => it.name == existingItem.itemName,
                            ),
                          );
                        }
                      }
                      final List<InventoryModel> searchResults = qSearch.isEmpty
                          ? <InventoryModel>[]
                          : all
                                .where(
                                  (it) =>
                                      it.name.toLowerCase().contains(
                                        qSearch.toLowerCase(),
                                      ) ||
                                      it.sku.toLowerCase().contains(
                                        qSearch.toLowerCase(),
                                      ),
                                )
                                .toList();
                      return Column(
                        children: [
                          _sidebarHeader(
                            existingItem == null ? "Add Item" : "Edit Item",
                            LucideIcons.plus,
                            c,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 32,
                                children: [
                                  KField(
                                    label: "Search Products",
                                    hintText: "Type name or sku...",
                                    onChanged: (v) =>
                                        setState(() => qSearch = v),
                                  ),
                                  if (searchResults.isNotEmpty && sel == null)
                                    _searchRes(
                                      searchResults,
                                      (it) => setState(() => sel = it),
                                    ),
                                  if (sel != null) ...[
                                    _selCard(
                                      sel!,
                                      () => setState(() => sel = null),
                                    ),
                                    Row(
                                      spacing: 20,
                                      children: [
                                        Expanded(
                                          child: KField(
                                            controller: qtyC,
                                            label: "Qty",
                                            keyboardType: TextInputType.number,
                                            onChanged: (v) => setState(() {}),
                                          ),
                                        ),
                                        Expanded(
                                          child: KField(
                                            controller: weightC,
                                            label: "Weight",
                                            keyboardType: TextInputType.number,
                                            onChanged: (v) => setState(() {}),
                                          ),
                                        ),
                                      ],
                                    ),
                                    _calcBox(sel!, weightC.text, qtyC.text),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          _sidebarFooter(
                            onCancel: () => Navigator.pop(c),
                            onSave: sel == null
                                ? null
                                : () => _save(
                                    id,
                                    sel!,
                                    weightC.text,
                                    qtyC.text,
                                    c,
                                  ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sidebarHeader(String t, IconData i, BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kColor(ctx).outlineVariant.withAlpha(100)),
        ),
      ),
      child: Row(
        children: [
          Icon(i, color: kColor(ctx).primary),
          const SizedBox(width: 16),
          Label(t, fontSize: 20, weight: 800).title,
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(LucideIcons.x),
          ),
        ],
      ),
    );
  }

  Widget _sidebarFooter({
    required VoidCallback onCancel,
    VoidCallback? onSave,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kColor(context).surfaceContainerLow,
        border: Border(
          top: BorderSide(color: kColor(context).outlineVariant.withAlpha(100)),
        ),
      ),
      child: Row(
        spacing: 16,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: Label("Cancel", weight: 700).regular,
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: kColor(context).primary,
                foregroundColor: Colors.white,
              ),
              child: Label("Save Item", weight: 800).regular,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchRes(List<InventoryModel> res, Function(InventoryModel) onSel) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: kColor(context).surfaceContainerHigh,
        borderRadius: kRadius(12),
      ),
      child: ListView.builder(
        itemCount: res.length,
        itemBuilder: (c, i) => ListTile(
          title: Label(res[i].name).regular,
          subtitle: Label("Stock: ${res[i].pieceStock}").regular,
          onTap: () => onSel(res[i]),
        ),
      ),
    );
  }

  Widget _selCard(InventoryModel it, VoidCallback onClear) {
    return FutureBuilder<List<MetalRateModel>>(
      future: DatabaseService.instance.getAllMetalRates(),
      builder: (context, snap) {
        double currentRate = 0;
        if (snap.hasData) {
          final m = snap.data!.firstWhere(
            (r) =>
                r.metalType.toLowerCase() == it.category.toLowerCase() &&
                (it.category != "Gold" || r.purity == it.purity),
            orElse: () =>
                MetalRateModel(metalType: "", purity: "", ratePer10g: 0),
          );
          currentRate = m.ratePer10g / 10;
        }

        return KCard(
          color: kColor(context).surfaceContainerHigh,
          padding: const EdgeInsets.all(24),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: kColor(context).primaryContainer,
                    child: Icon(
                      it.category == "Gold"
                          ? LucideIcons.gem
                          : LucideIcons.disc,
                      color: kColor(context).primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Label(it.name, weight: 800, fontSize: 18).regular,
                        Label(
                          "${it.category} • ${it.purity}",
                          color: kColor(context).onSurfaceVariant,
                        ).regular,
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(
                      LucideIcons.x,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const Divider(),
              Wrap(
                spacing: 32,
                runSpacing: 20,
                children: [
                  _detailItem("SKU", it.sku),
                  _detailItem("Stock (Pieces)", "${it.pieceStock.toInt()} Pcs"),
                  _detailItem(
                    "Stock (Weight)",
                    "${it.weightStock.toStringAsFixed(3)}g",
                  ),
                  _detailItem(
                    "Current Rate",
                    "Rs.${currentRate.toStringAsFixed(2)}/g",
                  ),
                  _detailItem(
                    "Making Charge",
                    "${it.makingCharges}${it.makingChargesType == 'Percent' ? '%' : ' Fixed'}",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Label(
          label,
          fontSize: 11,
          color: kColor(context).onSurfaceVariant,
          weight: 600,
        ).regular,
        Label(value, fontSize: 14, weight: 700).regular,
      ],
    );
  }

  Widget _calcBox(InventoryModel it, String wS, String qS) {
    return FutureBuilder<List<MetalRateModel>>(
      future: DatabaseService.instance.getAllMetalRates(),
      builder: (c, snap) {
        double r = 0;
        if (snap.hasData) {
          final m = snap.data!.firstWhere(
            (r) =>
                r.metalType.toLowerCase() == it.category.toLowerCase() &&
                (it.category != "Gold" || r.purity == it.purity),
            orElse: () =>
                MetalRateModel(metalType: "", purity: "", ratePer10g: 0),
          );
          r = m.ratePer10g / 10;
        }
        double w = parseToDouble(wS), q = parseToDouble(qS), val = w * r;
        double mc = 0;
        if (it.makingChargesType == "Percent") {
          mc = val * (it.makingCharges / 100);
        } else if (it.makingChargesType == "Per Gram") {
          mc = it.makingCharges * w;
        } else {
          // Default to Fixed (multiplied by qty)
          mc = it.makingCharges * q;
        }
        double taxAmt =
            (val * (metalGstRate / 100)) + (mc * (serviceGstRate / 100));
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kColor(context).surfaceContainer,
            borderRadius: kRadius(16),
          ),
          child: Column(
            spacing: 12,
            children: [
              _row("Metal Value", "Rs.${val.toStringAsFixed(2)}"),
              _row("Making Charges", "Rs.${mc.toStringAsFixed(2)}"),
              _row("Estimated Taxes", "Rs.${taxAmt.toStringAsFixed(2)}"),
              const Divider(),
              _row(
                "SUB TOTAL",
                "Rs.${(val + mc + taxAmt).toStringAsFixed(2)}",
                isBold: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String l, String v, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Label(l, weight: isBold ? 800 : 400).regular,
        Label(
          v,
          weight: isBold ? 900 : 700,
          color: isBold ? kColor(context).primary : null,
        ).regular,
      ],
    );
  }

  void _save(
    int id,
    InventoryModel it,
    String wS,
    String qS,
    BuildContext context,
  ) {
    DatabaseService.instance.getAllMetalRates().then((rates) {
      final r = rates.firstWhere(
        (r) =>
            r.metalType.toLowerCase() == it.category.toLowerCase() &&
            (it.category != "Gold" || r.purity == it.purity),
        orElse: () => MetalRateModel(metalType: "", purity: "", ratePer10g: 0),
      );
      double ratePerG = r.ratePer10g / 10,
          w = parseToDouble(wS),
          q = parseToDouble(qS),
          val = w * ratePerG;
      double mc = 0;
      if (it.makingChargesType == "Percent") {
        mc = val * (it.makingCharges / 100);
      } else if (it.makingChargesType == "Per Gram") {
        mc = it.makingCharges * w;
      } else {
        // Default to Fixed (multiplied by qty)
        mc = it.makingCharges * q;
      }
      double taxAmt =
          (val * (metalGstRate / 100)) + (mc * (serviceGstRate / 100));
      double taxable = val + mc;
      ItemModel data = ItemModel(
        id: id,
        itemName: it.name,
        sku: it.sku,
        weight: w,
        qty: q,
        unit: "Gms",
        price: q > 0 ? taxable / q : 0,
        amount: taxable,
        gst: taxable > 0 ? (taxAmt / taxable) * 100 : 0,
        metalGst: metalGstRate,
        serviceGst: serviceGstRate,
        metalAmount: val,
        serviceAmount: mc,
      );
      setState(() {
        int idx = addedItems.indexWhere((i) => i.id == id);
        if (idx != -1) {
          addedItems[idx] = data;
        } else {
          addedItems.add(data);
        }
      });
      Navigator.pop(context);
    });
  }
}
