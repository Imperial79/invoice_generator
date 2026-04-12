import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
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
import 'package:prime_invoice/Resources/app-data.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prime_invoice/Helper/responsive.dart';

class CreateInvoiceUI extends StatefulWidget {
  final InvoiceModel? invoice;
  const CreateInvoiceUI({super.key, this.invoice});

  @override
  State<CreateInvoiceUI> createState() => _CreateInvoiceUIState();
}

class _CreateInvoiceUIState extends State<CreateInvoiceUI> {
  DateTime invoiceDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final _customerFormKey = GlobalKey<FormState>();
  final tax = TextEditingController();
  final gst = TextEditingController();
  double metalGstRate = 3.0;
  double serviceGstRate = 18.0;

  List<String> tableFields = [
    "Sl.",
    "Description",
    "ITEM-SKU",
    "Weight",
    "Qty.",
    "Unit",
    "Price",
    "Amount",
  ];

  List<String> unitList = ["Gms", "Kg", "Pcs", "Nos"];

  List<ItemModel> addedItems = [];
  final invoiceNo = TextEditingController();
  final itemName = TextEditingController();
  final skuController = TextEditingController();
  final qty = TextEditingController();
  String unit = "Gms";
  final price = TextEditingController();
  double amount = 0;
  final billingAddress = TextEditingController(text: defaultBillingAddress);

  bool forCustomer = false;
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
    final bName = pref.getString("biz_name");
    final bAddress = pref.getString("biz_address");
    if (bName != null && widget.invoice == null) {
      // only if not editing
      // maybe add a field for biz name in form if needed, but currently it's for generating PDF
    }
    if (bAddress != null && widget.invoice == null) {
      setState(() {
        billingAddress.text = bAddress;
      });
    }
  }

  createInvoice() async {
    try {
      if (invoiceNo.text.trim().isEmpty) {
        invoiceNo.text =
            "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
      }

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
        final gstAmt = (item.amount * item.gst) / 100;
        total += item.amount + gstAmt;
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

      // Auto-save customer
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
        );
        await DatabaseService.instance.saveCustomer(customer);
      }

      await PdfHelper.generateInvoice(invoiceData);
      await DatabaseService.instance.saveInvoice(invoiceData);
      if (mounted) {
        // Navigator.pop(context, true);
        KSnackbar(
          context,
          message: "Invoice generated and saved successfully!",
        );
      }
    } catch (e) {
      log(e.toString());
      KSnackbar(context, message: e.toString(), error: true);
    } finally {
      isLoading.value = false;
    }
  }

  double calculateGst() {
    return (parseToDouble(gst.text) / 100) * amount;
  }

  clearFields() {
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
              if (data != null) {
                setState(() => invoiceDate = data);
              }
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
              primary: true,
              padding: const EdgeInsets.all(kPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
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
                      spacing: 30,
                      children: [
                        // LEFT SIDE: ITEMS LIST
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 20,
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
                        // RIGHT SIDE: BILLING DETAILS
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 20,
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
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createInvoice,
        icon: const Icon(LucideIcons.fileOutput),
        elevation: 4,
        backgroundColor: kColor(context).primary,
        foregroundColor: kColor(context).onPrimary,
        label: Label("Generate PDF", weight: 700).regular,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      spacing: 10,
      children: [
        Icon(icon, size: 20, color: kColor(context).secondary),
        Label(title, fontSize: 18, weight: 700).title,
      ],
    );
  }

  Widget _buildInvoiceInfo() {
    return KCard(
      padding: const EdgeInsets.all(15),
      borderWidth: 1,
      borderColor: kColor(context).outlineVariant,
      child: Column(
        spacing: 15,
        children: [
          KField(
            controller: invoiceNo,
            label: "Invoice No.",
            hintText: "Enter Unique ID",
            prefix: const Icon(LucideIcons.hash, size: 16),
            suffix: IconButton(
              onPressed: () => setState(() {
                invoiceNo.text =
                    "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
              }),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
            ),
            validator: (val) => KValidation.required(val),
          ),
          InkWell(
            onTap: () async {
              final data = await DateHelper.pickDate(
                context,
                currentDate: invoiceDate,
              );
              if (data != null) setState(() => invoiceDate = data);
            },
            child: KField(
              readOnly: true,
              showRequired: false,
              label: "Date",
              hintText: kDateFormat(invoiceDate.toString()),
              prefix: const Icon(LucideIcons.calendar, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        if (addedItems.isEmpty)
          _emptyItemsPlaceholder()
        else
          KCard(
            padding: EdgeInsets.zero,
            borderWidth: 1,
            borderColor: kColor(context).outlineVariant,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth:
                      MediaQuery.sizeOf(context).width *
                      0.6, // Approximate left column width
                ),
                child: ClipRRect(
                  borderRadius: kRadius(15),
                  child: DataTable(
                    horizontalMargin: 15,
                    columnSpacing: 0,
                    headingRowColor: WidgetStateProperty.all(
                      kColor(context).surfaceContainerLow,
                    ),
                    columns: [
                      DataColumn(
                        label: SizedBox(
                          width: 40,
                          child: Label("Sl.", weight: 700).regular,
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Label("Description", weight: 700).regular,
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 100,
                          child: Label("Weight", weight: 700).regular,
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 80,
                          child: Label("Qty", weight: 700).regular,
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 120,
                          child: Label("Net Payable", weight: 700).regular,
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 80,
                          child: Label("Actions", weight: 700).regular,
                        ),
                      ),
                    ],
                    rows: addedItems.map((item) {
                      int index = addedItems.indexOf(item) + 1;
                      return DataRow(
                        cells: [
                          DataCell(
                            SizedBox(width: 40, child: Label("$index").regular),
                          ),
                          DataCell(
                            // Using a wider container for Description to push other columns
                            Container(
                              constraints: const BoxConstraints(minWidth: 100),
                              child: Column(
                                crossAxisAlignment: .start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Label(item.itemName, weight: 600).regular,
                                  Label(
                                    item.sku,
                                    color: kColor(context).onSurfaceVariant,
                                    fontSize: 10,
                                    weight: 500,
                                  ).regular,
                                ],
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 100,
                              child: Label(
                                "${item.weight.toStringAsFixed(3)}g",
                              ).regular,
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 80,
                              child: Label(
                                "${item.qty.toStringAsFixed(0)} Pcs",
                              ).regular,
                            ),
                          ),

                          DataCell(
                            SizedBox(
                              width: 120,
                              child: Label(
                                "Rs.${item.amount.toStringAsFixed(2)}",
                                weight: 700,
                                color: kColor(context).primary,
                              ).regular,
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 80,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _editItem(item),
                                    icon: Icon(
                                      LucideIcons.pencil,
                                      size: 16,
                                      color: kColor(context).primary,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    onPressed: () =>
                                        setState(() => addedItems.remove(item)),
                                    icon: Icon(
                                      LucideIcons.trash2,
                                      size: 16,
                                      color: kColor(context).error,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
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
        KButton(
          onPressed: () {
            clearFields();
            showDialog(
              context: context,
              builder: (context) =>
                  addItemDialog(setState, id: addedItems.length + 1),
            );
          },
          style: KButtonStyle.expanded,
          label: "Add New Item",
          icon: const Icon(LucideIcons.plus),
        ),
      ],
    );
  }

  Widget _emptyItemsPlaceholder() {
    return KCard(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: kColor(context).surfaceContainerLow.withValues(alpha: .5),
      borderWidth: 1,
      borderColor: kColor(context).outlineVariant,
      child: Column(
        spacing: 10,
        children: [
          Icon(
            LucideIcons.inbox,
            size: 40,
            color: kColor(context).onSurfaceVariant,
          ),
          Label(
            "No items added yet",
            color: kColor(context).onSurfaceVariant,
          ).regular,
        ],
      ),
    );
  }

  void _editItem(ItemModel item) {
    showDialog(
      context: context,
      builder: (context) =>
          addItemDialog(setState, id: item.id, existingItem: item),
    );
  }

  Widget _buildOtherDetails() {
    return KCard(
      padding: const EdgeInsets.all(15),
      borderWidth: 1,
      borderColor: kColor(context).outlineVariant,
      child: KField(
        controller: billingAddress,
        maxLines: 4,
        minLines: 3,
        label: "Billing Address",
        hintText: "Enter complete billing address",
        validator: (val) => KValidation.required(val),
      ),
    );
  }

  Widget _buildSummarySection() {
    if (addedItems.isEmpty) return const SizedBox.shrink();

    double totalTaxableAmount = addedItems.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
    double totalGstAmount = addedItems.fold(
      0.0,
      (sum, item) => sum + (item.amount * item.gst / 100),
    );
    double totalAmount = totalTaxableAmount + totalGstAmount;

    return KCard(
      padding: const EdgeInsets.all(20),
      borderWidth: 1,
      borderColor: kColor(context).outlineVariant,
      child: Column(
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label("Sub Total (Before Tax)").regular,
              Label(kCurrencyFormat(totalTaxableAmount), weight: 600).regular,
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label("Total GST").regular,
              Label(kCurrencyFormat(totalGstAmount), weight: 600).regular,
            ],
          ),
          kDiv(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label("Grand Total", fontSize: 18, weight: 700).title,
              Label(
                kCurrencyFormat(totalAmount.round()),
                fontSize: 18,
                weight: 700,
                color: kColor(context).primary,
              ).title,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartyDetails() {
    return KCard(
      padding: const EdgeInsets.all(20),
      borderWidth: 1,
      borderColor: kColor(context).outlineVariant,
      child: Form(
        key: _customerFormKey,
        child: Column(
          spacing: 15,
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
            kDiv(context),
            KField(
              controller: customerName,
              label: "Customer Name",
              hintText: "Enter Name",
              prefix: const Icon(LucideIcons.user, size: 16),
              suffix: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showExistingClients(),
                    icon: Icon(
                      LucideIcons.users,
                      size: 18,
                      color: kColor(context).secondary,
                    ),
                    tooltip: "Choose from existing clients",
                  ),
                  IconButton(
                    onPressed: () async {
                      try {
                        if (await FlutterContacts.requestPermission()) {
                          final contact =
                              await FlutterContacts.openExternalPick();
                          if (contact != null) {
                            setState(() {
                              customerName.text = contact.displayName;
                              if (contact.phones.isNotEmpty) {
                                customerPhone.text = contact.phones.first.number
                                    .replaceAll(RegExp(r'[^0-9]'), '');
                                if (customerPhone.text.length > 10 &&
                                    customerPhone.text.startsWith('91')) {
                                  customerPhone.text = customerPhone.text
                                      .substring(2);
                                }
                              }
                            });
                          }
                        } else {
                          KSnackbar(
                            context,
                            message: "Contact permission denied!",
                            error: true,
                          );
                        }
                      } catch (e) {
                        log("Contact Pick Error: $e");
                        KSnackbar(
                          context,
                          message: "Couldn't pick contact",
                          error: true,
                        );
                      }
                    },
                    icon: Icon(
                      LucideIcons.contact,
                      size: 18,
                      color: kColor(context).primary,
                    ),
                    tooltip: "Pick from contacts",
                  ),
                ],
              ),
              validator: (val) => KValidation.required(val),
            ),
            KField(
              controller: customerPhone,
              label: "Phone Number",
              hintText: "10 Digit Mobile",
              prefix: const Icon(LucideIcons.phone, size: 16),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: (val) => KValidation.phone(val),
            ),
            Row(
              spacing: 15,
              children: [
                Expanded(
                  child: KField(
                    controller: customerPan,
                    label: "PAN",
                    hintText: "Optional",
                    showRequired: false,
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                Expanded(
                  child: KField(
                    controller: customerAadhaar,
                    label: "Aadhaar",
                    hintText: "Optional",
                    showRequired: false,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            KField(
              controller: customerGst,
              label: "GSTIN",
              hintText: "Optional",
              showRequired: false,
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
      ),
    );
  }

  void _showExistingClients() async {
    isLoading.value = true;
    final customers = await DatabaseService.instance.getAllCustomers();
    isLoading.value = false;

    if (customers.isEmpty) {
      if (mounted) {
        KSnackbar(context, message: "No existing clients found!", error: true);
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          String search = "";
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final filtered = customers
                  .where(
                    (c) =>
                        c.name.toLowerCase().contains(search.toLowerCase()) ||
                        c.phone.contains(search),
                  )
                  .toList();

              return _dialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 15,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Label(
                          "Select Existing Client",
                          fontSize: 18,
                          weight: 700,
                        ).title,
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(LucideIcons.x, size: 20),
                        ),
                      ],
                    ),
                    KField(
                      hintText: "Search name or phone",
                      prefix: const Icon(LucideIcons.search, size: 16),
                      onChanged: (v) => setDialogState(() => search = v),
                    ),
                    kDiv(context),
                    if (filtered.isEmpty)
                      Center(
                        child: Label(
                          "No results",
                          color: kColor(context).onSurfaceVariant,
                        ).regular,
                      )
                    else
                      ...filtered.map(
                        (client) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: kColor(context).primaryContainer,
                            child: Icon(
                              LucideIcons.user,
                              size: 18,
                              color: kColor(context).onPrimaryContainer,
                            ),
                          ),
                          title: Label(client.name, weight: 600).regular,
                          subtitle: Label(client.phone, fontSize: 12).regular,
                          onTap: () {
                            setState(() {
                              customerName.text = client.name;
                              customerPhone.text = client.phone;
                              customerPan.text = client.pan;
                              customerGst.text = client.gst;
                              customerAadhaar.text = client.aadhaar;
                              // Optionally update address if customer has one
                              if (client.address.isNotEmpty) {
                                billingAddress.text = client.address;
                              }
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  Widget _dialog({required Widget child}) {
    return Dialog(
      constraints: BoxConstraints(maxWidth: 1000),
      shape: RoundedRectangleBorder(borderRadius: kRadius(20)),
      backgroundColor: kColor(context).surface,
      insetPadding: const EdgeInsets.all(kPadding),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(child: child),
      ),
    );
  }

  Widget addItemDialog(
    StateSetter setMainState, {
    required int id,
    ItemModel? existingItem,
  }) {
    InventoryModel? selectedInventory;
    List<InventoryModel> allInventory = [];
    String searchQuery = "";

    // Initialize controllers with existing data if editing
    final weightC = TextEditingController(
      text: existingItem != null
          ? (existingItem.weight / existingItem.qty).toStringAsFixed(3)
          : "",
    );
    final qtyC = TextEditingController(
      text: existingItem != null ? existingItem.qty.toString() : "1",
    );

    // Local controller for item name if needed, or use parent's if consistent
    final localItemName = TextEditingController(
      text: existingItem?.itemName ?? "",
    );

    return StatefulBuilder(
      builder: (context, setState) {
        return _dialog(
          child: FutureBuilder<List<InventoryModel>>(
            future: allInventory.isEmpty
                ? DatabaseService.instance.getAllInventory()
                : Future.value(allInventory),
            builder: (context, snapshot) {
              if (snapshot.hasData && allInventory.isEmpty) {
                allInventory = snapshot.data!;
                // If editing, find the corresponding inventory item
                if (existingItem != null && selectedInventory == null) {
                  final match = allInventory.firstWhere(
                    (item) => item.sku == existingItem.sku,
                    orElse: () => allInventory.firstWhere(
                      (item) => item.name == existingItem.itemName,
                    ),
                  );
                  selectedInventory = match;
                }
              }

              final searchResults = searchQuery.isEmpty
                  ? []
                  : allInventory
                        .where(
                          (item) =>
                              item.name.toLowerCase().contains(
                                searchQuery.toLowerCase(),
                              ) ||
                              item.sku.toLowerCase().contains(
                                searchQuery.toLowerCase(),
                              ),
                        )
                        .toList();

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 15,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Label(
                          "Item Details #$id",
                          fontSize: 20,
                          weight: 700,
                        ).title,
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(LucideIcons.x, size: 20),
                        ),
                      ],
                    ),
                    kDiv(context),

                    // 1. SEARCH PRODUCT
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KField(
                          label: "Search Inventory",
                          hintText: "Search by Name or SKU...",
                          prefix: const Icon(LucideIcons.search, size: 18),
                          onChanged: (v) => setState(() => searchQuery = v),
                        ),
                        if (searchResults.isNotEmpty &&
                            selectedInventory == null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              color: kColor(context).surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: kColor(context).outlineVariant,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: searchResults.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: kColor(context).outlineVariant,
                              ),
                              itemBuilder: (context, index) {
                                final item = searchResults[index];
                                return ListTile(
                                  onTap: () {
                                    setState(() {
                                      selectedInventory = item;
                                      itemName.text = item.name;
                                      // DO NOT auto-fill weight/qty as requested
                                      searchQuery = ""; // hide list
                                    });
                                  },
                                  leading: Icon(
                                    LucideIcons.package2,
                                    size: 18,
                                    color: kColor(context).primary,
                                  ),
                                  title: Label(
                                    item.name,
                                    fontSize: 14,
                                    weight: 600,
                                  ).regular,
                                  subtitle: Label(
                                    "SKU: ${item.sku} • Stock: ${item.stock}",
                                    fontSize: 12,
                                  ).regular,
                                  trailing: Label(
                                    item.category,
                                    fontSize: 11,
                                    color: kColor(context).primary,
                                  ).regular,
                                );
                              },
                            ),
                          ),
                      ],
                    ),

                    // 2. INPUT FIELDS & CALCULATIONS
                    FutureBuilder<List<MetalRateModel>>(
                      future: DatabaseService.instance.getAllMetalRates(),
                      builder: (context, snapshot) {
                        double metalRatePerGram = 0;
                        if (snapshot.hasData && selectedInventory != null) {
                          final rates = snapshot.data!;
                          final match = rates.firstWhere(
                            (r) =>
                                r.metalType.toLowerCase() ==
                                    selectedInventory!.category.toLowerCase() &&
                                (selectedInventory!.category != "Gold" ||
                                    r.purity == selectedInventory!.purity),
                            orElse: () => MetalRateModel(
                              metalType: "",
                              purity: "",
                              ratePer10g: 0,
                            ),
                          );
                          metalRatePerGram = match.ratePer10g / 10;
                        }

                        // Calculations based on Inputs
                        double w = parseToDouble(weightC.text);
                        double q = parseToDouble(qtyC.text);
                        double totalWeight = w * q;
                        double metalPrice = totalWeight * metalRatePerGram;

                        double makingCharge = 0;
                        if (selectedInventory != null) {
                          if (selectedInventory!.makingChargesType ==
                              "Percent") {
                            makingCharge =
                                metalPrice *
                                (selectedInventory!.makingCharges / 100);
                          } else {
                            makingCharge = selectedInventory!.makingCharges * q;
                          }
                        }

                        double taxableAmt = metalPrice + makingCharge;

                        // Use settings-based GST rates
                        double metalGstAmt = metalPrice * (metalGstRate / 100);
                        double serviceGstAmt =
                            makingCharge * (serviceGstRate / 100);
                        double totalGstAmt = metalGstAmt + serviceGstAmt;

                        double effectiveGstRate = taxableAmt > 0
                            ? (totalGstAmt / taxableAmt) * 100
                            : 0;

                        double totalPayable = taxableAmt + totalGstAmt;

                        return Column(
                          spacing: 15,
                          children: [
                            // 2.1 SELECTED PRODUCT DETAILS (CARD)
                            if (selectedInventory != null)
                              KCard(
                                padding: const EdgeInsets.all(12),
                                color: kColor(context).surfaceContainer,
                                borderColor: kColor(context).outlineVariant,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.info,
                                          size: 16,
                                          color: kColor(context).primary,
                                        ),
                                        width10,
                                        Expanded(
                                          child: Label(
                                            "${selectedInventory!.name} • ${selectedInventory!.category} • ${selectedInventory!.purity}\nStock: ${selectedInventory!.stock} • Unit Wt: ${selectedInventory!.weight}g",
                                            fontSize: 13,
                                            weight: 600,
                                          ).regular,
                                        ),
                                        IconButton(
                                          onPressed: () => setState(
                                            () => selectedInventory = null,
                                          ),
                                          icon: const Icon(
                                            LucideIcons.circleX,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            // 2.2 QTY AND WEIGHT INPUTS
                            Row(
                              spacing: 12,
                              children: [
                                Expanded(
                                  child: KField(
                                    controller: qtyC,
                                    label: "Qty (Pieces)",
                                    hintText: "0",
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => setState(() {}),
                                  ),
                                ),
                                Expanded(
                                  child: KField(
                                    controller: weightC,
                                    label: "Weight (per Piece)",
                                    hintText: "0.000",
                                    suffix: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Label("Gms", fontSize: 13).regular,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),

                            // 2.3 CALCULATIONS SECTION (BREAKDOWN)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: kColor(
                                  context,
                                ).primaryContainer.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: kColor(context).primary.withAlpha(100),
                                ),
                              ),
                              child: Column(
                                spacing: 8,
                                children: [
                                  _calcRow(
                                    "Total Weight",
                                    "${totalWeight.toStringAsFixed(3)} Gms",
                                  ),
                                  _calcRow(
                                    "Metal Price ${selectedInventory != null ? "(${selectedInventory!.category})" : ""}",
                                    selectedInventory != null
                                        ? "Rs.${metalPrice.toStringAsFixed(2)}"
                                        : "Rs.0.00",
                                    subValue: selectedInventory != null
                                        ? "(@Rs.${metalRatePerGram.toStringAsFixed(2)}/g)"
                                        : null,
                                  ),
                                  _calcRow(
                                    "Making Charge ${selectedInventory != null ? "(${selectedInventory!.makingChargesType == 'Percent' ? "${selectedInventory!.makingCharges}%" : "Fixed"})" : ""}",
                                    selectedInventory != null
                                        ? "Rs.${makingCharge.toStringAsFixed(2)}"
                                        : "Rs.0.00",
                                  ),
                                  const Divider(),
                                  _calcRow(
                                    "Taxable Amount",
                                    "Rs.${taxableAmt.toStringAsFixed(2)}",
                                    isBold: true,
                                  ),
                                  _calcRow(
                                    "Metal GST ($metalGstRate%)",
                                    "Rs.${metalGstAmt.toStringAsFixed(2)}",
                                  ),
                                  _calcRow(
                                    "Service GST ($serviceGstRate%)",
                                    "Rs.${serviceGstAmt.toStringAsFixed(2)}",
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: kColor(context).primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Label(
                                          "TOTAL PAYABLE",
                                          color: Colors.white,
                                          weight: 700,
                                        ).regular,
                                        Label(
                                          "Rs.${totalPayable.toStringAsFixed(2)}",
                                          color: Colors.white,
                                          fontSize: 16,
                                          weight: 900,
                                        ).regular,
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            KButton(
                              onPressed: selectedInventory == null
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        ItemModel data = ItemModel(
                                          id: id,
                                          itemName:
                                              localItemName.text.trim().isEmpty
                                              ? selectedInventory!.name
                                              : localItemName.text.trim(),
                                          sku: selectedInventory!.sku,
                                          weight: totalWeight,
                                          qty: q,
                                          unit: "Gms",
                                          price: q > 0
                                              ? taxableAmt / q
                                              : 0, // Price per piece including MC but before GST
                                          amount:
                                              taxableAmt, // Total taxable amount
                                          gst: effectiveGstRate,
                                          metalGst: metalGstRate,
                                          serviceGst: serviceGstRate,
                                          metalAmount: metalPrice,
                                          serviceAmount: makingCharge,
                                        );

                                        setMainState(() {
                                          int index = addedItems.indexWhere(
                                            (item) => item.id == id,
                                          );
                                          if (index != -1) {
                                            addedItems[index] = data;
                                          } else {
                                            addedItems.add(data);
                                          }
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                              label: id <= addedItems.length
                                  ? "Update Item"
                                  : "Add to Invoice",
                              icon: const Icon(LucideIcons.shoppingCart),
                              style: KButtonStyle.expanded,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _calcRow(
    String label,
    String value, {
    String? subValue,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Label(label, fontSize: 12, weight: isBold ? 700 : 400).regular,
            if (subValue != null)
              Label(subValue, fontSize: 10, color: Colors.grey).regular,
          ],
        ),
        Label(value, fontSize: 13, weight: isBold ? 900 : 600).regular,
      ],
    );
  }
}
