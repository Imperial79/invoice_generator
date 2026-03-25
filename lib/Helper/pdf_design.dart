import 'package:invoice_generator/Models/Invoice_Model.dart';
import 'package:invoice_generator/Resources/app-data.dart';
import 'package:invoice_generator/Resources/constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

final PdfColor primaryColor = PdfColor.fromHex("#0068A5");
final PdfColor secondaryColor = PdfColor.fromHex("#2b2c43");
final PdfColor lightGrey = PdfColor.fromHex("#f6f6f6");
final PdfColor borderGrey = PdfColor.fromHex("#dadada");

Widget pdfLayout(
  Context context,
  MemoryImage banner,
  MemoryImage watermark,
  InvoiceModel data,
  bool showWatermark,
) {
  return Stack(
    children: [
      if (showWatermark)
        FullPage(
          ignoreMargins: true,
          child: Opacity(
            opacity: 0.1,
            child: Center(child: Image(watermark, width: 400)),
          ),
        ),
      Column(
        children: [
          Container(
            width: double.infinity,
            child: Image(banner, fit: BoxFit.contain),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvoiceHeader(data),
                SizedBox(height: 20),
                _buildAddressSection(data),
                SizedBox(height: 30),
                _buildItemsTable(data),
                SizedBox(height: 20),
                _buildTotalSection(data),
                SizedBox(height: 30),
                _buildTermsAndSignature(),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildInvoiceHeader(InvoiceModel data) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "GST INVOICE",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          Text("GSTIN: $kGSTCode", style: const TextStyle(fontSize: 10)),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _headerInfo("Invoice No:", data.invoiceId),
          _headerInfo("Date:", kDateFormat(data.invoiceDate.toString())),
          _headerInfo("State:", "West Bengal (19)"),
        ],
      ),
    ],
  );
}

Widget _headerInfo(String label, String value) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "$label ",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
      ),
      Text(value, style: const TextStyle(fontSize: 10)),
    ],
  );
}

Widget _buildAddressSection(InvoiceModel data) {
  return Row(
    children: [
      Expanded(child: _addressBox("BILLED TO", data)),
      SizedBox(width: 20),
      if (!data.forCustomer) Expanded(child: _addressBox("SHIPPED TO", data)),
    ],
  );
}

Widget _addressBox(String title, InvoiceModel data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        color: primaryColor,
        child: Text(
          title,
          style: TextStyle(
            color: PdfColors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(height: 5),
      Text(
        data.customerName,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      Text(data.billingAddress, style: const TextStyle(fontSize: 9)),
      SizedBox(height: 5),
      if (data.customerPhone.isNotEmpty)
        Text(
          "Phone: +91 ${data.customerPhone}",
          style: const TextStyle(fontSize: 9),
        ),
      if (data.customerPan.isNotEmpty)
        Text("PAN: ${data.customerPan}", style: const TextStyle(fontSize: 9)),
    ],
  );
}

Widget _buildItemsTable(InvoiceModel data) {
  return TableHelper.fromTextArray(
    headerAlignment: Alignment.centerLeft,
    cellAlignment: Alignment.centerLeft,
    headerDecoration: BoxDecoration(
      color: primaryColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
    ),
    headerHeight: 30,
    cellHeight: 25,
    headerStyle: TextStyle(
      color: PdfColors.white,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    ),
    cellStyle: const TextStyle(fontSize: 9),
    rowDecoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: PdfColors.grey200, width: .5)),
    ),
    headers: [
      'Sl.',
      'Description',
      'HSN/SAC',
      'Qty',
      'Unit',
      'Price',
      'Amount',
    ],
    data: data.items.map((item) {
      return [
        item.id.toString(),
        item.itemName,
        item.hsnCode,
        item.qty.toString(),
        item.unit,
        kCurrencyFormat(item.price),
        kCurrencyFormat(item.amount),
      ];
    }).toList(),
  );
}

Widget _buildTotalSection(InvoiceModel data) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Amount in words:",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            Text(
              amountInWords(data.grandTotal.round()),
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      Expanded(
        flex: 1,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: lightGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              _totalRow(
                "Sub Total:",
                kCurrencyFormat(data.grandTotal - _calculateTotalGst(data)),
              ),
              SizedBox(height: 5),
              _totalRow(
                "Total GST:",
                kCurrencyFormat(_calculateTotalGst(data)),
              ),
              SizedBox(height: 5),
              Divider(thickness: .5, color: borderGrey),
              SizedBox(height: 5),
              _totalRow(
                "Total (INR):",
                kCurrencyFormat(data.grandTotal.round()),
                isBold: true,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

double _calculateTotalGst(InvoiceModel data) {
  double gst = 0;
  for (var item in data.items) {
    gst += (item.amount * item.gst) / 100;
  }
  return gst;
}

Widget _totalRow(String label, String value, {bool isBold = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  );
}

Widget _buildTermsAndSignature() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        flex: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bank Details:",
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
            Text(
              "Bank Name: SBI Bank, Durgapur Sen Market",
              style: const TextStyle(fontSize: 8),
            ),
            Text(
              "A/C No: 8718927918219871 | IFSC: SBIN0001234",
              style: const TextStyle(fontSize: 8),
            ),
            SizedBox(height: 10),
            Text(
              "Terms & Conditions:",
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
            Text(
              "1. Goods once sold will not be taken back.",
              style: const TextStyle(fontSize: 8),
            ),
            Text(
              "2. Interest @18% will be charged on late payments.",
              style: const TextStyle(fontSize: 8),
            ),
          ],
        ),
      ),
      Expanded(
        flex: 1,
        child: Column(
          children: [
            Text(
              "Authorized Signatory",
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Container(
              width: 100,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide()),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
