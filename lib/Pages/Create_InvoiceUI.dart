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
import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:prime_invoice/Models/Item_Model.dart';
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

  List<String> tableFields = [
    "Sl.",
    "Description",
    "HSN/ASC",
    "Qty.",
    "Unit",
    "Price",
    "Amount",
  ];

  List<String> unitList = ["Gms", "Kg", "Pcs", "Nos"];

  List<ItemModel> addedItems = [];
  final invoiceNo = TextEditingController();
  final itemName = TextEditingController();
  final hsnCode = TextEditingController();
  final qty = TextEditingController();
  String unit = "Gms";
  final price = TextEditingController();
  double amount = 0;
  final billingAddress = TextEditingController(text: defaultBillingAddress);

  bool forCustomer = false;
  final customerName = TextEditingController();
  final customerPhone = TextEditingController();
  final customerPan = TextEditingController();
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
      customerAadhaar.text = inv.customerAadhaar;
      billingAddress.text = inv.billingAddress;
      addedItems = List.from(inv.items);
      forCustomer = inv.forCustomer;
    } else {
      invoiceNo.text =
          "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    }
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
        billingAddress: billingAddress.text,
        grandTotal: total,
        invoiceDate: invoiceDate,
      );
      await PdfHelper.generateInvoice(invoiceData);
      await DatabaseService.instance.saveInvoice(invoiceData);
      if (mounted) {
        Navigator.pop(context, true);
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
    hsnCode.clear();
    qty.clear();
    price.clear();
    gst.clear();
  }

  @override
  void dispose() {
    invoiceNo.dispose();
    itemName.dispose();
    hsnCode.dispose();
    qty.dispose();
    price.dispose();
    tax.dispose();
    gst.dispose();
    billingAddress.dispose();
    customerName.dispose();
    customerPhone.dispose();
    customerPan.dispose();
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
            constraints: const BoxConstraints(maxWidth: 1000),
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
                    _buildSectionHeader("Items List", LucideIcons.package),
                    _buildItemsSection(),
                    _buildSummarySection(),
                    _buildSectionHeader("Party Details", LucideIcons.user),
                    _buildPartyDetails(),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 30,
                      children: [
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
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
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
                      ],
                    ),
                  ],
                  _buildSectionHeader("Other Details", LucideIcons.ellipsis),
                  KField(
                    controller: billingAddress,
                    maxLines: 4,
                    minLines: 3,
                    label: "Billing Address",
                    hintText: "Enter complete billing address",
                    validator: (val) => KValidation.required(val),
                  ),
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
      spacing: 15,
      children: [
        if (addedItems.isEmpty)
          KCard(
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
          )
        else
          ...addedItems.map((item) => _buildItemCard(item)),
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

  Widget _buildItemCard(ItemModel item) {
    return KCard(
      padding: const EdgeInsets.all(15),
      borderWidth: 1,
      borderColor: kColor(context).primary.withValues(alpha: .2),
      color: kColor(context).surface,
      child: Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(item.itemName, fontSize: 16, weight: 700).title,
              Row(
                spacing: 10,
                children: [
                  IconButton(
                    onPressed: () {
                      itemName.text = item.itemName;
                      hsnCode.text = item.hsnCode;
                      qty.text = item.qty.toString();
                      unit = item.unit;
                      price.text = item.price.toString();
                      amount = item.amount;
                      gst.text = item.gst.toString();
                      showDialog(
                        context: context,
                        builder: (context) =>
                            addItemDialog(setState, id: item.id),
                      );
                    },
                    icon: Icon(
                      LucideIcons.pencil,
                      size: 18,
                      color: kColor(context).primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => addedItems.remove(item)),
                    icon: Icon(
                      LucideIcons.trash2,
                      size: 18,
                      color: kColor(context).error,
                    ),
                  ),
                ],
              ),
            ],
          ),
          kDiv(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _itemStat("Qty", "${item.qty} ${item.unit}"),
              _itemStat("Rate", kCurrencyFormat(item.price)),
              _itemStat("GST", "${item.gst}%"),
              _itemStat("Total", kCurrencyFormat(item.amount), isBold: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemStat(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label(
          label,
          fontSize: 10,
          color: kColor(context).onSurfaceVariant,
        ).regular,
        Label(value, fontSize: 13, weight: isBold ? 700 : 500).regular,
      ],
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
                                  customerPhone.text =
                                      customerPhone.text.substring(2);
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
          ],
        ),
      ),
    );
  }

  void _showExistingClients() async {
    isLoading.value = true;
    final invoices = await DatabaseService.instance.getAllInvoices();
    final uniqueClients = <String, InvoiceModel>{};
    for (var inv in invoices) {
      final key = "${inv.customerName}-${inv.customerPhone}";
      if (!uniqueClients.containsKey(key)) {
        uniqueClients[key] = inv;
      }
    }
    isLoading.value = false;

    if (uniqueClients.isEmpty) {
      if (mounted) {
        KSnackbar(context, message: "No existing clients found!", error: true);
      }
      return;
    }

    final clientList = uniqueClients.values.toList();

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          String search = "";
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final filtered = clientList
                  .where(
                    (c) =>
                        c.customerName.toLowerCase().contains(
                          search.toLowerCase(),
                        ) ||
                        c.customerPhone.contains(search),
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
                          title: Label(client.customerName, weight: 600).regular,
                          subtitle:
                              Label(client.customerPhone, fontSize: 12).regular,
                          onTap: () {
                            setState(() {
                              customerName.text = client.customerName;
                              customerPhone.text = client.customerPhone;
                              customerPan.text = client.customerPan;
                              customerAadhaar.text = client.customerAadhaar;
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

  Widget addItemDialog(StateSetter setMainState, {required int id}) {
    return StatefulBuilder(
      builder: (context, setState) {
        return _dialog(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Label("Item Details #$id", fontSize: 20, weight: 700).title,
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(LucideIcons.x, size: 20),
                    ),
                  ],
                ),
                kDiv(context),
                KField(
                  controller: itemName,
                  label: "Item Name",
                  hintText: "e.g. Graphic Design Services",
                  validator: (val) => KValidation.required(val),
                ),
                KField(
                  controller: hsnCode,
                  label: "HSN/SAC Code",
                  hintText: "e.g. 9983",
                  textCapitalization: TextCapitalization.characters,
                ),
                if (Responsive.isMobile(context)) ...[
                  KField(
                    controller: qty,
                    label: "Qty",
                    keyboardType: TextInputType.number,
                    validator: (val) => KValidation.required(val),
                    onChanged: (v) => setState(() {
                      amount = (parseToDouble(v) * parseToDouble(price.text));
                    }),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      Label("Unit", fontSize: 13, weight: 600).regular,
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: unitList.map((e) {
                          final isSelected = unit == e;
                          return ChoiceChip(
                            label: Label(e, fontSize: 12).regular,
                            selected: isSelected,
                            onSelected: (v) {
                              if (v) setState(() => unit = e);
                            },
                            showCheckmark: false,
                            selectedColor: kColor(context).primaryContainer,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? kColor(context).onPrimaryContainer
                                  : kColor(context).onSurface,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: kRadius(10),
                              side: BorderSide(
                                color: isSelected
                                    ? kColor(context).primary
                                    : kColor(context).outlineVariant,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ] else
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        flex: 2,
                        child: KField(
                          controller: qty,
                          label: "Qty",
                          keyboardType: TextInputType.number,
                          validator: (val) => KValidation.required(val),
                          onChanged: (v) => setState(() {
                            amount =
                                (parseToDouble(v) * parseToDouble(price.text));
                          }),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            Label("Unit", fontSize: 13, weight: 600).regular,
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: unitList.map((e) {
                                final isSelected = unit == e;
                                return ChoiceChip(
                                  label: Label(e, fontSize: 12).regular,
                                  selected: isSelected,
                                  onSelected: (v) {
                                    if (v) setState(() => unit = e);
                                  },
                                  showCheckmark: false,
                                  selectedColor: kColor(
                                    context,
                                  ).primaryContainer,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? kColor(context).onPrimaryContainer
                                        : kColor(context).onSurface,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: kRadius(10),
                                    side: BorderSide(
                                      color: isSelected
                                          ? kColor(context).primary
                                          : kColor(context).outlineVariant,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: KField(
                        controller: price,
                        label: "Rate/Price",
                        prefixText: "₹",
                        keyboardType: TextInputType.number,
                        validator: (val) => KValidation.required(val),
                        onChanged: (v) => setState(() {
                          amount = (parseToDouble(v) * parseToDouble(qty.text));
                        }),
                      ),
                    ),
                    Expanded(
                      child: KField(
                        controller: gst,
                        label: "GST (%)",
                        suffix: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Label("%", fontSize: 16).regular,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) => KValidation.required(val),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Label("Total Amount", fontSize: 20, weight: 900).regular,
                    Label(
                      kCurrencyFormat(amount, symbol: "₹"),
                      fontSize: 17,
                      weight: 700,
                    ).regular,
                  ],
                ),
                KButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ItemModel data = ItemModel(
                        id: id,
                        itemName: itemName.text.trim(),
                        hsnCode: hsnCode.text.trim(),
                        gst: parseToDouble(gst.text),
                        unit: unit,
                        qty: parseToDouble(qty.text),
                        price: parseToDouble(price.text),
                        amount: parseToDouble(amount),
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
                  label: id <= addedItems.length ? "Update Item" : "Add Item",
                  icon: const Icon(LucideIcons.check),
                  style: KButtonStyle.expanded,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
