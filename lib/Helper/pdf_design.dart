import 'package:invoice_generator/Models/Invoice_Model.dart';
import 'package:invoice_generator/Resources/app-data.dart';
import 'package:invoice_generator/Resources/constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

PdfColor black = PdfColor.fromHex("#000000");

Divider get div => Divider(
      thickness: 1,
      height: 0,
      color: black,
    );

Widget pdfLayout(
  Context context,
  MemoryImage banner,
  MemoryImage watermark,
  InvoiceModel data,
) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Image(watermark),
      Column(
        children: [
          Center(
            child: Image(banner),
          ),
          Container(
            margin: EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(border: Border.all(color: black)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: boldLabel(
                          "GST: $kGSTCode",
                        ),
                      ),
                      Expanded(
                        child: boldLabel(
                          "GST Invoice",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: label(
                          "Original Buyer's Copy",
                          italic: true,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),

                TableHelper.fromTextArray(
                  context: context,
                  headerStyle:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
                  cellAlignment: Alignment.topLeft,
                  data: [
                    [
                      'Invoice No. : ${data.invoiceId}\nDate of Invoice : ${kDateFormat(data.invoiceDate.toString())}',
                      'Place of Supply : West Bengal\nReverse Charge : N',
                    ],
                  ],
                  cellAlignments: {
                    0: Alignment.topLeft,
                    1: Alignment.topLeft,
                  },
                ),

                // Shipped and Billed To
                TableHelper.fromTextArray(
                  context: context,
                  headerStyle:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
                  cellAlignment: Alignment.topLeft,
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
GSTIN / UIN : -
''',
                            '''
Shipped to:
${data.customerName}
${data.billingAddress}
Party PAN : ${data.customerPan}
Party Aadhaar No. : ${data.customerAadhaar}
Party Mobile No. : ${data.customerPhone}
GSTIN / UIN : -
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
GSTIN / UIN : -
'''
                          ],
                  ],
                  cellAlignments: {
                    0: Alignment.topLeft,
                    1: Alignment.topLeft,
                  },
                ),

                TableHelper.fromTextArray(
                  context: context,
                  data: [
                    [
                      "Sl. No.",
                      "Description of Goods",
                      "HSN/SAC Code",
                      "Qty.",
                      "Unit",
                      "Price",
                      "Amount (Rs.)",
                    ],
                    ...data.items.map(
                      (e) => [
                        e.id,
                        e.itemName,
                        e.hsnCode,
                        e.qty,
                        e.unit,
                        e.price,
                        e.amount,
                      ],
                    ),
                  ],
                ),

                TableHelper.fromTextArray(
                  context: context,
                  headerStyle:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
                  columnWidths: {
                    0: FixedColumnWidth(70),
                    1: FixedColumnWidth(30),
                  },
                  cellAlignments: {
                    0: Alignment.topRight,
                    1: Alignment.topRight,
                  },
                  data: [
                    [
                      '''
${data.items.map(
                            (e) => '''
Add : CGST @ ${(e.gst / 2).toStringAsFixed(2)}%
Add : SGST @ ${(e.gst / 2).toStringAsFixed(2)}%
''',
                          ).join("")}
''',
                      '''
${data.items.map(
                            (e) => '''
${((e.amount * (e.gst / 2)) / 100).toStringAsFixed(2)}
${((e.amount * (e.gst / 2)) / 100).toStringAsFixed(2)}
''',
                          ).join("")}
'''
                    ],
                  ],
                ),
                TableHelper.fromTextArray(
                  context: context,
                  columnWidths: {
                    0: FixedColumnWidth(70),
                    1: FixedColumnWidth(30),
                  },
                  cellAlignments: {
                    0: Alignment.topRight,
                    1: Alignment.topRight,
                  },
                  data: [
                    [
                      '''
Grand Total (Rs.)
''',
                      '''
${kCurrencyFormat(data.grandTotal)}
'''
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
                        data: [
                          [
                            'Tax Rate',
                            'Taxable Amt.',
                            'CGST Amt.',
                            'SGST Amt.',
                            'Total Tax'
                          ],
                          ...data.items.map((e) {
                            double tax = e.gst;
                            double taxableAmount = e.amount;
                            double cgstAmt = (taxableAmount * (tax / 2)) / 100;
                            return [
                              '$tax%',
                              kCurrencyFormat(taxableAmount),
                              kCurrencyFormat(cgstAmt),
                              kCurrencyFormat(cgstAmt),
                              kCurrencyFormat(cgstAmt * 2)
                            ];
                          }),
                        ],
                      ),
                      SizedBox(height: 15),
                      boldLabel(
                          "Rupees Thirty Five Thousand One Hundred Sizty Only",
                          fontSize: 12),
                    ],
                  ),
                ),

                TableHelper.fromTextArray(
                  context: context,
                  headerAlignment: Alignment.center,
                  headerStyle:
                      TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  cellStyle:
                      TextStyle(fontSize: 9, fontWeight: FontWeight.normal),
                  cellAlignment: Alignment.center,
                  data: [
                    ["Declaration"],
                    [
                      '''
BANK DETAILS - SBI BANK, DURGAPUR SEN MARKET - A/C - 8718927918219871, IFSC - AKSLJASKLAAS
SOUTH INDIAN BANK - ABC ROAD, - A/C - 8718927918219871, IFSC - AKSLJASKLAAS
(1) RATES INCLUDING MAKING CHARGE (2) GOODS DELIVERED AT OUR SHOP
'''
                    ],
                  ],
                ),

                TableHelper.fromTextArray(
                  context: context,
                  headerAlignment: Alignment.topLeft,
                  headerStyle:
                      TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  cellStyle:
                      TextStyle(fontSize: 9, fontWeight: FontWeight.normal),
                  cellAlignment: Alignment.topLeft,
                  data: [
                    ["Terms & Conditions"],
                    [
                      '''
E. & O.E.
1. Goods once sold will not be taken back.
2. Goods once sold will not be taken back.
3. Goods once sold will not be taken back.
''',
                      '''
Reciever's Signature


---------------------------------------
'''
                    ],
                  ],
                ),
                TableHelper.fromTextArray(
                  context: context,
                  cellStyle:
                      TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  headerAlignment: Alignment.topRight,
                  cellAlignment: Alignment.topRight,
                  border: TableBorder(bottom: BorderSide.none),
                  data: [
                    [
                      '''
Authorized Signatory




'''
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      )
    ],
  );
}

Widget boldLabel(
  String text, {
  TextAlign textAlign = TextAlign.start,
  bool italic = false,
  double fontSize = 10,
}) =>
    Text(
      text,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
          fontStyle: italic ? FontStyle.italic : null),
      textAlign: textAlign,
    );

Widget label(String text,
        {TextAlign textAlign = TextAlign.start, bool italic = false}) =>
    Text(
      text,
      style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 10,
          fontStyle: italic ? FontStyle.italic : null),
      textAlign: textAlign,
    );
