import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_generator/Essentials/KScaffold.dart';
import 'package:invoice_generator/Essentials/Label.dart';
import 'package:invoice_generator/Essentials/kButton.dart';
import 'package:invoice_generator/Essentials/kField.dart';
import 'package:invoice_generator/Helper/date_helper.dart';
import 'package:invoice_generator/Models/Item_Model.dart';
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
  final _taxFormKey = GlobalKey<FormState>();
  final tax = TextEditingController();
  final sgst = TextEditingController();
  final cgst = TextEditingController();

  List<String> tableFields = [
    "Sl. No.",
    "Item Description",
    "HSN/ASC Code",
    "Qty.",
    "Unit",
    "Price",
    "Amount (₹)"
  ];
  List<String> taxFields = [
    "Item",
    "Tax (%)",
    "Action",
  ];

  List<String> unitList = ["Gms", "Kg"];

  List<ItemModel> addedItems = [];
  List addedTax = [];

  final itemName = TextEditingController();
  final hsnCode = TextEditingController();
  final qty = TextEditingController();
  String unit = "Gms";
  final price = TextEditingController();
  final amount = TextEditingController();

  clearFields() {
    itemName.clear();
    hsnCode.clear();
    qty.clear();
    price.clear();
    amount.clear();
  }

  @override
  void dispose() {
    itemName.dispose();
    hsnCode.dispose();
    qty.dispose();
    price.dispose();
    amount.dispose();
    tax.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
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
          padding: EdgeInsets.only(bottom: kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(kPadding),
                child: KField(
                  label: "Invoice No.",
                  hintText: "Unique No.",
                  keyboardType: TextInputType.number,
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
                    showBottomBorder: true,
                    columns: [...tableFields, "Action"]
                        .map(
                          (e) => DataColumn(label: Label(e).regular),
                        )
                        .toList(),
                    rows: addedItems
                        .map(
                          (item) => DataRow(
                            color: WidgetStatePropertyAll(
                              kColor(context).primaryContainer.lighten(
                                  addedItems.indexOf(item) % 2 == 0 ? .7 : .1),
                            ),
                            cells: [
                              DataCell(Label("${item.id}").regular),
                              DataCell(Label(item.itemName).regular),
                              DataCell(Label(item.hsnCode).regular),
                              DataCell(Label("${item.qty}").regular),
                              DataCell(Label(item.unit).regular),
                              DataCell(
                                  Label(kCurrencyFormat(item.price)).regular),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: kPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 5,
                      children: [
                        Label("GST").title,
                        Label("(Optional)", fontStyle: FontStyle.italic)
                            .subtitle,
                      ],
                    ),
                    Label(
                      "The GST will be applied for each item added",
                      fontStyle: FontStyle.italic,
                    ).subtitle,
                    height15,
                    Row(
                      spacing: 10,
                      children: [
                        Flexible(
                          child: KField(
                            prefixText: "CGST",
                            hintText: "0.00",
                            keyboardType: TextInputType.number,
                            suffix: Label("%").regular,
                          ),
                        ),
                        Flexible(
                          child: KField(
                            prefixText: "SGST",
                            hintText: "0.00",
                            keyboardType: TextInputType.number,
                            suffix: Label("%").regular,
                          ),
                        ),
                      ],
                    ),
                    height20,
                    Label("TAX").title,
                    height10,
                    MaterialButton(
                      onPressed: () {
                        if (addedItems.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                addTaxDialog(setState, id: addedTax.length + 1),
                          );
                        } else {
                          KSnackbar(context,
                              message: "Add items first!", error: true);
                        }
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
                            Icon(Icons.add_circle_outline,
                                size: 20, color: Kolor.primary),
                            Label("Add Tax", color: Kolor.primary).regular,
                          ],
                        ),
                      ),
                    ),
                    if (addedTax.isNotEmpty)
                      SingleChildScrollView(
                        child: DataTable(
                            columns: taxFields
                                .map(
                                  (e) => DataColumn(
                                    label: Label(e).regular,
                                  ),
                                )
                                .toList(),
                            rows: addedTax
                                .map(
                                  (e) => DataRow(
                                    cells: [
                                      DataCell(Label("#1").regular),
                                      DataCell(Label("1.2").regular),
                                      DataCell(
                                        Row(
                                          spacing: 5,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.edit,
                                                size: 15, color: Kolor.primary),
                                            Label("Edit", color: Kolor.primary)
                                                .regular,
                                          ],
                                        ),
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                )
                                .toList()),
                      )
                    else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Column(
                            children: [
                              Label(
                                "%",
                                fontSize: 50,
                                weight: 900,
                                color: Kolor.primary.lighten(),
                              ).regular,
                              Label(
                                "No Added Tax",
                                fontSize: 30,
                                color: Kolor.primary.lighten(),
                              ).regular,
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              height20,
              div,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
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
    StateSetter setState, {
    required int id,
  }) {
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
            ),
            height10,
            KField(
              controller: hsnCode,
              label: "HSN/SAC Code",
              hintText: "Enter HSN/SAC Code",
              validator: (val) => KValidation.required(val),
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
              prefixText: "INR / ₹",
              keyboardType: TextInputType.number,
              validator: (val) => KValidation.required(val),
            ),
            height10,
            KField(
              controller: amount,
              label: "Amount",
              hintText: "Enter Amount",
              prefixText: "INR / ₹",
              keyboardType: TextInputType.number,
              validator: (val) => KValidation.required(val),
            ),
            height20,
            KButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ItemModel data = ItemModel.fromMap({
                    "id": id,
                    "itemName": itemName.text,
                    "hsnCode": hsnCode.text,
                    "unit": unit,
                    "qty": int.parse(qty.text),
                    "price": parseToDouble(price.text),
                    "amount": parseToDouble(amount.text),
                  });

                  setState(() {
                    int index = addedItems.indexWhere((item) => item.id == id);
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
  }

  Widget addTaxDialog(
    StateSetter setState, {
    required int id,
  }) {
    return _dialog(
      child: Form(
        key: _taxFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Label("Add Tax for Item #$id").title,
            height20,
            Label("Item").subtitle,
            Label(addedItems[id - 1].itemName).title,
            height20,
            KField(
              controller: tax,
              label: "Tax (%)",
              hintText: "Enter Tax",
              keyboardType:
                  TextInputType.numberWithOptions(decimal: true, signed: false),
              suffix: Label("%").title,
              validator: (val) => KValidation.required(val),
            ),
            height20,
            KButton(
              onPressed: () {
                if (_taxFormKey.currentState!.validate()) {
                  final taxData = {
                    "item": id,
                    "tax": parseToDouble(tax.text),
                  };

                  setState(() {
                    int index =
                        addedTax.indexWhere((item) => item["item"] == id);
                    if (index != -1) {
                      addedTax[index] = taxData;
                      KSnackbar(context, message: "Tax updated for Item #$id.");
                    } else {
                      addedTax.add(taxData);
                      KSnackbar(context, message: "Tax added for Item #$id.");
                    }
                  });

                  tax.clear();
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
  }
}
