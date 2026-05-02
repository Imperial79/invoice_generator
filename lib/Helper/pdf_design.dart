import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

// final PdfColor black = PdfColor.fromHex("#000000");
final PdfColor grey = PdfColor.fromHex("#adadad");

List<Widget> pdfLayout(
  Context context,
  MemoryImage? banner,
  InvoiceModel data,
  Map<String, dynamic> profile,
) {
  return [
    if (banner != null) Center(child: Image(banner)),
    SizedBox(height: 10),
    // HEADER (GST INFO) - Using a Table to keep the border and layout
    Table(
      border: TableBorder.all(color: grey),
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: boldLabel("GST: ${profile['biz_gst']}"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: boldLabel("GST Invoice", textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: label(
                "Original Buyer's Copy",
                italic: true,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    ),

    TableHelper.fromTextArray(
      context: context,
      headerStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
      cellAlignment: Alignment.topLeft,
      border: TableBorder.all(color: grey),
      data: [
        [
          'Invoice No. : ${data.invoiceId}\nDate of Invoice : ${kDateFormat(data.invoiceDate.toString())}',
          'Place of Supply : ${profile['biz_state']}\nReverse Charge : N',
        ],
      ],
      cellAlignments: {0: Alignment.topLeft, 1: Alignment.topLeft},
    ),

    // Shipped and Billed To
    TableHelper.fromTextArray(
      context: context,
      headerStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
      cellAlignment: Alignment.topLeft,
      border: TableBorder.all(color: grey),
      data: [
        !data.forCustomer
            ? [
                '''
Billed to:
${data.customerName}
${data.billingAddress}
Party PAN : ${data.customerPan}
Party Aadhaar No. : ${data.customerAadhaar}
Party Mobile No. : ${data.customerPhone}
GSTIN / UIN : ${data.customerGst.isNotEmpty ? data.customerGst : '-'}
''',
                '''
Shipped to:
${data.customerName}
${data.billingAddress}
Party PAN : ${data.customerPan}
Party Aadhaar No. : ${data.customerAadhaar}
Party Mobile No. : ${data.customerPhone}
GSTIN / UIN : ${data.customerGst.isNotEmpty ? data.customerGst : '-'}
''',
              ]
            : [
                '''
Billed to:
${data.customerName}
${data.billingAddress}
Party PAN : ${data.customerPan}
Party Aadhaar No. : ${data.customerAadhaar}
Party Mobile No. : ${data.customerPhone}
GSTIN / UIN : ${data.customerGst.isNotEmpty ? data.customerGst : '-'}
''',
              ],
      ],
      cellAlignments: {0: Alignment.topLeft, 1: Alignment.topLeft},
    ),

    TableHelper.fromTextArray(
      context: context,
      border: TableBorder.all(color: grey),
      data: [
        [
          "Sl. No.",
          "Description of Goods",
          "ITEM SKU",
          "Weight",
          "Qty.",
          "Unit",
          "Price",
          "Amount (Rs.)",
        ],
        ...data.items.map(
          (e) => [
            e.id.toString(),
            e.itemName,
            e.sku,
            "${e.weight.toStringAsFixed(3)} Gms",
            e.qty.toString(),
            e.unit,
            e.price.toStringAsFixed(2),
            e.amount.toStringAsFixed(2),
          ],
        ),
      ],
    ),

    TableHelper.fromTextArray(
      context: context,
      headerStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
      columnWidths: {0: FixedColumnWidth(70), 1: FixedColumnWidth(30)},
      cellAlignments: {0: Alignment.topRight, 1: Alignment.topRight},
      border: TableBorder.all(color: grey),
      data: [
        [
          '''
${data.items.map((e) {
            String res = "";
            if (e.metalAmount > 0) {
              res += "Add : CGST (Metal) @ ${(e.metalGst / 2).toStringAsFixed(2)}% on Rs.${e.metalAmount.toStringAsFixed(2)}\n";
              res += "Add : SGST (Metal) @ ${(e.metalGst / 2).toStringAsFixed(2)}% on Rs.${e.metalAmount.toStringAsFixed(2)}\n";
            }
            if (e.serviceAmount > 0) {
              res += "Add : CGST (Service) @ ${(e.serviceGst / 2).toStringAsFixed(2)}% on Rs.${e.serviceAmount.toStringAsFixed(2)}\n";
              res += "Add : SGST (Service) @ ${(e.serviceGst / 2).toStringAsFixed(2)}% on Rs.${e.serviceAmount.toStringAsFixed(2)}\n";
            }
            return res;
          }).join("")}
Less: Round Off (-)
''',
          '''
${data.items.map((e) {
            String res = "";
            if (e.metalAmount > 0) {
              double mGst = (e.metalAmount * (e.metalGst / 2)) / 100;
              res += "${mGst.toStringAsFixed(2)}\n${mGst.toStringAsFixed(2)}\n";
            }
            if (e.serviceAmount > 0) {
              double sGst = (e.serviceAmount * (e.serviceGst / 2)) / 100;
              res += "${sGst.toStringAsFixed(2)}\n${sGst.toStringAsFixed(2)}\n";
            }
            return res;
          }).join("")}
${(data.grandTotal.round() - data.grandTotal).toStringAsFixed(2)}
''',
        ],
      ],
    ),
    TableHelper.fromTextArray(
      context: context,
      columnWidths: {0: FixedColumnWidth(70), 1: FixedColumnWidth(30)},
      cellAlignments: {0: Alignment.topRight, 1: Alignment.topRight},
      border: TableBorder.all(color: grey),
      data: [
        [
          '''
Grand Total (Rs.)
''',
          '''
${kCurrencyFormat(data.grandTotal.round())}
''',
        ],
      ],
    ),

    Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableHelper.fromTextArray(
            tableWidth: TableWidth.min,
            context: context,
            border: TableBorder.all(color: grey),
            data: [
              [
                'Tax Rate',
                'Taxable Amt.',
                'CGST Amt.',
                'SGST Amt.',
                'Total Tax',
              ],
              ...data.items.expand((e) {
                List<List<String>> rows = [];
                if (e.metalAmount > 0) {
                  double mGst = (e.metalAmount * e.metalGst) / 100;
                  rows.add([
                    '${e.metalGst}% (Metal)',
                    kCurrencyFormat(e.metalAmount),
                    kCurrencyFormat(mGst / 2),
                    kCurrencyFormat(mGst / 2),
                    kCurrencyFormat(mGst),
                  ]);
                }
                if (e.serviceAmount > 0) {
                  double sGst = (e.serviceAmount * e.serviceGst) / 100;
                  rows.add([
                    '${e.serviceGst}% (Service)',
                    kCurrencyFormat(e.serviceAmount),
                    kCurrencyFormat(sGst / 2),
                    kCurrencyFormat(sGst / 2),
                    kCurrencyFormat(sGst),
                  ]);
                }
                return rows;
              }),
            ],
          ),
          SizedBox(height: 15),
          boldLabel(amountInWords(data.grandTotal.round()), fontSize: 12),
        ],
      ),
    ),

    TableHelper.fromTextArray(
      context: context,
      cellStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      headerAlignment: Alignment.topRight,
      cellAlignment: Alignment.topRight,
      border: TableBorder(
        top: BorderSide(color: grey),
        left: BorderSide(color: grey),
        right: BorderSide(color: grey),
        verticalInside: BorderSide(color: grey),
        horizontalInside: BorderSide(color: grey),
        bottom: BorderSide.none,
      ),
      data: [
        [
          '''
Authorized Signatory




''',
        ],
      ],
    ),

    TableHelper.fromTextArray(
      context: context,
      headerAlignment: Alignment.center,
      headerStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      cellStyle: TextStyle(fontSize: 8, fontWeight: FontWeight.normal),
      cellAlignment: Alignment.center,
      border: TableBorder.all(color: grey),
      data: [
        ["Declaration"],
        [
          '''
${profile['biz_bank']}
${profile['biz_declaration']}
''',
        ],
      ],
    ),

    TableHelper.fromTextArray(
      context: context,
      headerAlignment: Alignment.topLeft,
      headerStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      cellStyle: TextStyle(fontSize: 8, fontWeight: FontWeight.normal),
      cellAlignment: Alignment.topLeft,
      border: TableBorder.all(color: grey),
      data: [
        ["Terms & Conditions"],
        [
          '''
${profile['biz_terms']}
''',
          '''
Reciever's Signature


---------------------------------------
''',
        ],
      ],
    ),
  ];
}

Widget boldLabel(
  String text, {
  TextAlign textAlign = TextAlign.start,
  bool italic = false,
  double fontSize = 10,
}) => Text(
  text,
  style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: fontSize,
    fontStyle: italic ? FontStyle.italic : null,
  ),
  textAlign: textAlign,
);

Widget label(
  String text, {
  TextAlign textAlign = TextAlign.start,
  bool italic = false,
}) => Text(
  text,
  style: TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 10,
    fontStyle: italic ? FontStyle.italic : null,
  ),
  textAlign: textAlign,
);
