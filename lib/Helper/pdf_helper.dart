import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:invoice_generator/Helper/pdf_design.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfHelper {
  static Future<void> generateInvoice() async {
    final pdf = pw.Document(
      compress: false,
    );
    final img = await rootBundle.load('assets/images/invoice-banner.png');
    final imageBytes = img.buffer.asUint8List();

    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pdfLayout(context, image);
          // return pw.Column(
          //   crossAxisAlignment: pw.CrossAxisAlignment.start,
          //   children: [
          //     // Leave space for header image
          //     pw.Container(height: 100),

          //     pw.Text(
          //       'GST INVOICE',
          //       style: pw.TextStyle(
          //         font: customFont,
          //         fontSize: 18,
          //         fontWeight: pw.FontWeight.bold,
          //       ),
          //     ),
          //     pw.SizedBox(height: 10),

          //     pw.Text('Invoice No: 2460',
          //         style: pw.TextStyle(font: customFont)),
          //     pw.Text('Date of Invoice: 28-12-2024',
          //         style: pw.TextStyle(font: customFont)),

          //     pw.SizedBox(height: 10),
          //     pw.Text('Billed to:', style: pw.TextStyle(font: customFont)),
          //     pw.Text('SHRI KRISHN JEWELLERS',
          //         style: pw.TextStyle(font: customFont)),
          //     pw.Text('Arrah Kali Nagar, Ground Floor, Satyam Residency',
          //         style: pw.TextStyle(font: customFont)),
          //     pw.Text('Jawahar Lal Nehru Road, Durgaapur, West Bengal',
          //         style: pw.TextStyle(font: customFont)),

          //     pw.SizedBox(height: 10),
          //     pw.Text('Shipped to:', style: pw.TextStyle(font: customFont)),
          //     pw.Text('SHRI KRISHN JEWELLERS',
          //         style: pw.TextStyle(font: customFont)),
          //     pw.Text('Arrah Kali Nagar, Ground Floor, Satyam Residency',
          //         style: pw.TextStyle(font: customFont)),

          //     pw.SizedBox(height: 10),
          //     pw.Text('Products:', style: pw.TextStyle(font: customFont)),
          //     pw.TableHelper.fromTextArray(
          //       context: context,
          //       data: [
          //         ['Description', 'HSN/SAC', 'Qty', 'Unit Price', 'Amount'],
          //         [
          //           '22k Gold Ornaments',
          //           '71131910',
          //           '4.50g',
          //           '7,659.43',
          //           '34,084.46'
          //         ],
          //         ['Hallmark Charges', '998346', '1 pcs', '45.00', '45.00'],
          //       ],
          //       cellStyle: pw.TextStyle(font: customFont),
          //       headerStyle: pw.TextStyle(
          //         font: customFont,
          //         fontWeight: pw.FontWeight.bold,
          //       ),
          //     ),

          //     pw.SizedBox(height: 10),
          //     pw.Text(
          //       'Total Amount: INR 35,160.00',
          //       style: pw.TextStyle(
          //         font: customFont,
          //         fontSize: 14,
          //         fontWeight: pw.FontWeight.bold,
          //       ),
          //     ),
          //   ],
          // );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice.pdf');
    await file.writeAsBytes(await pdf.save());
    log("PDF Saved to ${file.path}");

    // Open the PDF file
    final result = await OpenFile.open(file.path);
    log("OpenFile result: ${result.message}");
  }
}
