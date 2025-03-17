import 'package:flutter/material.dart';
import 'package:invoice_generator/Essentials/KScaffold.dart';
import 'package:invoice_generator/Essentials/Label.dart';
import 'package:invoice_generator/Essentials/kButton.dart';
import 'package:invoice_generator/Essentials/kCard.dart';
import 'package:invoice_generator/Essentials/kField.dart';
import 'package:invoice_generator/Helper/date_helper.dart';
import 'package:invoice_generator/Helper/pdf_helper.dart';
import 'package:invoice_generator/Models/Invoice_Model.dart';
import 'package:invoice_generator/Models/Item_Model.dart';
import 'package:invoice_generator/Resources/app-data.dart';
import 'package:invoice_generator/Resources/colors.dart';
import 'package:invoice_generator/Resources/commons.dart';
import 'package:invoice_generator/Resources/constants.dart';

class CreateInvoiceUI extends StatefulWidget {
  const CreateInvoiceUI({super.key});

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
    "Sl. No.",
    "Item Description",
    "HSN/ASC Code",
    "Qty.",
    "Unit",
    "Price",
    "GST (%)",
    "Amount (₹)"
  ];
  List<String> taxFields = [
    "Item",
    "Tax (%)",
    "Action",
  ];

  List<String> unitList = ["Gms", "Kg"];

  List<ItemModel> addedItems = [];
  final invoiceNo = TextEditingController();
  final itemName = TextEditingController();
  final hsnCode = TextEditingController();
  final qty = TextEditingController();
  String unit = "Gms";
  final price = TextEditingController();
  final amount = TextEditingController();
  final billingAddress = TextEditingController(text: defaultBillingAddress);

  bool forCustomer = false;
  final customerName = TextEditingController();
  final customerPhone = TextEditingController();
  final customerPan = TextEditingController();
  final customerAadhaar = TextEditingController();
  final isLoading = ValueNotifier(false);

  createInvoice() async {
    try {
      FocusScope.of(context).unfocus();
      isLoading.value = true;
      if (!_customerFormKey.currentState!.validate()) {
        KSnackbar(context,
            message: "Enter ${forCustomer ? "Customer" : "Shop Owner"} Details",
            error: true);
        return;
      }
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
    } catch (e) {
      KSnackbar(context, message: e, error: true);
    } finally {
      isLoading.value = false;
    }
  }

  double calculateGst() {
    return (parseToDouble(gst.text) / 100) * parseToDouble(amount.text);
  }

  clearFields() {
    itemName.clear();
    hsnCode.clear();
    qty.clear();
    price.clear();
    amount.clear();
    gst.clear();
  }

  @override
  void dispose() {
    itemName.dispose();
    hsnCode.dispose();
    qty.dispose();
    price.dispose();
    amount.dispose();
    tax.dispose();
    gst.dispose();
    billingAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(
        context,
        title: kDateFormat("$invoiceDate"),
        actions: [
          IconButton(
            onPressed: () async {
              final data = await DateHelper.pickDate(
                context,
                currentDate: invoiceDate,
              );
              if (data != null) {
                setState(() {
                  invoiceDate = data;
                });
              }
            },
            icon: Icon(Icons.date_range),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(kPadding),
                child: KField(
                  controller: invoiceNo,
                  label: "Invoice No.",
                  hintText: "Unique No.",
                  keyboardType: TextInputType.number,
                  suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        invoiceNo.text =
                            "${DateTime.now().millisecondsSinceEpoch}";
                      });
                    },
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.sync,
                      size: 22,
                    ),
                  ),
                  validator: (val) => KValidation.required(val),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kPadding),
                child: MaterialButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => addItemDialog(
                        setState,
                        id: addedItems.length + 1,
                      ),
                    );
                  },
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: kRadius(10),
                    side: BorderSide(color: Kolor.primary.lighten(.4)),
                  ),
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        Icon(Icons.add_circle, size: 20, color: Kolor.primary),
                        Label("Add Items", color: Kolor.primary).regular,
                      ],
                    ),
                  ),
                ),
              ),
              if (addedItems.isNotEmpty)
                SingleChildScrollView(
                  padding: EdgeInsets.all(kPadding),
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    dividerThickness: 0,
                    headingRowColor: WidgetStatePropertyAll(Kolor.primary),
                    headingRowHeight: 35,
                    clipBehavior: Clip.hardEdge,
                    border: TableBorder.all(
                      color: Kolor.primary.lighten(),
                      borderRadius: kRadius(10),
                      width: 1,
                    ),
                    headingTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    columns: [...tableFields, "Action"]
                        .map(
                          (e) => DataColumn(label: Label(e).regular),
                        )
                        .toList(),
                    rows: addedItems
                        .map(
                          (item) => DataRow(
                            cells: [
                              DataCell(Label("${item.id}").regular),
                              DataCell(
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 200),
                                  child: Label(item.itemName).regular,
                                ),
                              ),
                              DataCell(Label(item.hsnCode).regular),
                              DataCell(Label("${item.qty}").regular),
                              DataCell(Label(item.unit).regular),
                              DataCell(
                                  Label(kCurrencyFormat(item.price)).regular),
                              DataCell(
                                Label("${item.gst}%").regular,
                              ),
                              DataCell(
                                Label(kCurrencyFormat(item.amount)).regular,
                              ),
                              DataCell(
                                Row(
                                  spacing: 5,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit,
                                        size: 15, color: Kolor.primary),
                                    Label("Edit", color: Kolor.primary).regular,
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    itemName.text = item.itemName;
                                    hsnCode.text = item.hsnCode;
                                    qty.text = "${item.qty}";
                                    unit = item.unit;
                                    price.text = "${item.price}";
                                    amount.text = "${item.amount}";
                                    gst.text = "${item.gst}";
                                  });
                                  showDialog(
                                    context: context,
                                    builder: (context) => addItemDialog(
                                      setState,
                                      id: item.id,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                )
              else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 50,
                          color: Kolor.primary.lighten(),
                        ),
                        Label(
                          "No Item(s)",
                          fontSize: 30,
                          color: Kolor.primary.lighten(),
                        ).regular,
                      ],
                    ),
                  ),
                ),
              height20,
              div,
              Padding(
                padding: EdgeInsets.all(kPadding),
                child: Label("Tax Breakdown").regular,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: kPadding),
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(Kolor.primary),
                  headingRowHeight: 35,
                  clipBehavior: Clip.hardEdge,
                  dividerThickness: 0,
                  border: TableBorder.all(
                    color: Kolor.primary.lighten(),
                    borderRadius: kRadius(10),
                    width: 1,
                  ),
                  headingTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  columns: [
                    "Tax Rate",
                    "Taxable Amt.",
                    "CGST Amt.",
                    "SGST Amt.",
                    "Total Tax"
                  ]
                      .map(
                        (e) => DataColumn(label: Label(e).regular),
                      )
                      .toList(),
                  rows: addedItems.map(
                    (item) {
                      double tax = item.gst;
                      double taxableAmount = item.amount;
                      double cgst = (taxableAmount * (tax / 2)) / 100;

                      return DataRow(
                        cells: [
                          DataCell(Label("$tax%").regular),
                          DataCell(
                              Label(kCurrencyFormat(taxableAmount)).regular),
                          DataCell(Label(kCurrencyFormat(cgst)).regular),
                          DataCell(Label(kCurrencyFormat(cgst)).regular),
                          DataCell(Label(kCurrencyFormat(cgst * 2)).regular),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ),
              height20,
              Padding(
                padding: EdgeInsets.all(kPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KCard(
                      child: Row(
                        spacing: 10,
                        children: [
                          Expanded(child: Label("For Customer").title),
                          Switch(
                            value: forCustomer,
                            onChanged: (value) {
                              setState(() {
                                forCustomer = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    KCard(
                      color: Kolor.scaffold,
                      borderWidth: 1,
                      margin: EdgeInsets.only(top: 15),
                      child: Form(
                        key: _customerFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Label("Enter ${forCustomer ? "Customer" : "Shop Owner"} Details")
                                .regular,
                            div,
                            height10,
                            KField(
                              controller: customerName,
                              label: "Name",
                              hintText: "Eg. Name Surname",
                              validator: (val) => KValidation.required(val),
                            ),
                            height10,
                            KField(
                              controller: customerPhone,
                              label: "Phone",
                              hintText: "Eg. 1234567890",
                              prefixText: "+91",
                              keyboardType: TextInputType.number,
                              validator: (val) => KValidation.required(val),
                            ),
                            height10,
                            KField(
                              controller: customerPan,
                              label: "PAN (Optional)",
                              hintText: "Eg. CHDPV7772W",
                              textCapitalization: TextCapitalization.characters,
                            ),
                            height10,
                            KField(
                              controller: customerAadhaar,
                              label: "Aadhaar (Optional)",
                              hintText: "Eg. 12345678912",
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ],
                        ),
                      ),
                    ),
                    height20,
                    Label("Other Details").title,
                    height10,
                    KField(
                      controller: billingAddress,
                      maxLines: 4,
                      minLines: 4,
                      label: "Billing Address",
                      hintText: "Enter a billing address",
                      validator: (val) => KValidation.required(val),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          createInvoice();
        },
        icon: Icon(Icons.picture_as_pdf),
        elevation: 0,
        backgroundColor: Kolor.primary,
        foregroundColor: Colors.white,
        label: Label("Create PDF").regular,
      ),
    );
  }

  Widget _dialog({required Widget child}) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: kRadius(15)),
      backgroundColor: Kolor.scaffold,
      insetPadding: EdgeInsets.all(kPadding),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(kPadding),
        child: SingleChildScrollView(child: child),
      ),
    );
  }

  Widget addItemDialog(
    StateSetter setMainState, {
    required int id,
  }) {
    return StatefulBuilder(builder: (context, setState) {
      return _dialog(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Label("Add Item #$id").title,
              height20,
              KField(
                controller: itemName,
                label: "Item Name",
                hintText: "Enter item name",
                validator: (val) => KValidation.required(val),
                onChanged: (val) {
                  setState(() {});
                },
              ),
              height10,
              KField(
                controller: hsnCode,
                label: "HSN/SAC Code",
                hintText: "Enter HSN/SAC Code",
                textCapitalization: TextCapitalization.characters,
                validator: (val) => KValidation.required(val),
                onChanged: (val) {
                  setState(() {});
                },
              ),
              height10,
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: KField(
                      controller: qty,
                      label: "Qty",
                      hintText: "Enter Qty",
                      keyboardType: TextInputType.number,
                      suffix: DropdownButton(
                        value: unit,
                        underline: SizedBox(),
                        items: unitList
                            .map(
                              (e) => DropdownMenuItem<String>(
                                value: e,
                                child: Label(e).regular,
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            if (value != null) {
                              unit = value;
                            }
                          });
                        },
                      ),
                      validator: (val) => KValidation.required(val),
                    ),
                  ),
                ],
              ),
              height10,
              KField(
                controller: price,
                label: "Price",
                hintText: "Enter Price",
                prefixText: "INR",
                keyboardType: TextInputType.number,
                validator: (val) => KValidation.required(val),
                onChanged: (val) {
                  setState(() {
                    amount.text = (parseToDouble(val) * parseToDouble(qty.text))
                        .toStringAsFixed(2);
                    calculateGst();
                  });
                },
              ),
              height10,
              Row(
                spacing: 10,
                children: [
                  Flexible(
                    child: KField(
                      controller: amount,
                      label: "Amount",
                      showRequired: false,
                      readOnly: true,
                      hintText: "Enter Amount",
                      prefixText: "INR",
                      keyboardType: TextInputType.number,
                      validator: (val) => KValidation.required(val),
                    ),
                  ),
                  Flexible(
                    child: KField(
                      controller: gst,
                      label: "GST",
                      hintText: "Enter GST",
                      suffix: Label("%").title,
                      keyboardType: TextInputType.number,
                      validator: (val) => KValidation.required(val),
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              height15,
              Row(
                children: [
                  Expanded(child: Label("GST (${gst.text}%)").regular),
                  Label(kCurrencyFormat((parseToDouble(gst.text) / 100) *
                          parseToDouble(amount.text)))
                      .regular,
                  height20,
                ],
              ),
              height15,
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
                      amount: parseToDouble(amount.text),
                    );

                    setMainState(() {
                      int index =
                          addedItems.indexWhere((item) => item.id == id);
                      if (index != -1) {
                        addedItems[index] = data;
                        KSnackbar(context, message: "Item updated.");
                      } else {
                        addedItems.add(data);
                        KSnackbar(context, message: "Item added.");
                      }
                    });
                    clearFields();
                    Navigator.pop(context);
                  }
                },
                label: "Add Item",
                icon: Icon(Icons.add),
                visualDensity: VisualDensity.comfortable,
                style: KButtonStyle.expanded,
              ),
            ],
          ),
        ),
      );
    });
  }
}
