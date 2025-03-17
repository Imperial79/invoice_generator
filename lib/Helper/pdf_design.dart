import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

PdfColor black = PdfColor.fromHex("#000000");

Divider get div => Divider(
      thickness: 1,
      height: 0,
      color: black,
    );

Widget pdfLayout(Context context, MemoryImage image) {
  return Column(children: [
    Center(
      child: Image(image),
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
                    "GST: 18278127AHJS",
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
          // div,
          TableHelper.fromTextArray(
            context: context,
            headerStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
            cellAlignment: Alignment.topLeft,
            data: [
              [
                'Invoice No. : 1209\nDate of Invoice : 1827891',
                'Invoice No. : 1209\nDate of Invoice : 1827891',
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
            headerStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
            cellAlignment: Alignment.topLeft,
            data: [
              [
                '''
Billed to:
Some Name
Address Line 1,
Address Line 2,
Address Line 3,
Party PAN : ASJASHJKASJKH
Party Aadhaar No. : ASJASHJKASJKH
Party Mobile No. : 1234567890
GSTIN / UIN : ASJASHJKASJKHJSHAKS
''',
                '''
Shipped to:
Some Name
Address Line 1,
Address Line 2,
Address Line 3,
Party PAN : ASJASHJKASJKH
Party Aadhaar No. : ASJASHJKASJKH
Party Mobile No. : 1234567890
GSTIN / UIN : ASJASHJKASJKHJSHAKS
''',
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
              [
                "1",
                "22K Gold Ring",
                "817287",
                "67.8",
                "Gms.",
                "18,279",
                "1,72,177",
              ],
              [
                "2",
                "HALLMARK CHARGES",
                "1728",
                "1.000",
                "Pcs.",
                "45.00",
                "45.00",
              ],
            ],
          ),

          TableHelper.fromTextArray(
            context: context,
            headerStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
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
Add : CGST @ 1.50%
Add : SGST @ 1.50%
Add : CGST @ 9%
Add : SGST @ 9%
''',
                '''
511.27
511.27
4.05
4.05
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
35,000.00
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
                    ['3%', '34,000.00', '511.20', '511.20', '1,000'],
                    ['3%', '34,000.00', '511.20', '511.20', '1,000'],
                  ],
                ),
                SizedBox(height: 15),
                boldLabel("Rupees Thirty Five Thousand One Hundred Sizty Only",
                    fontSize: 12),
              ],
            ),
          ),

          TableHelper.fromTextArray(
            context: context,
            headerAlignment: Alignment.center,
            headerStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            cellStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.normal),
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
            headerStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            cellStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.normal),
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
            cellStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
    )
  ]);
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
