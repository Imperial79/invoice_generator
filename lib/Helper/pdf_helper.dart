import 'dart:developer';
import 'dart:io';
import 'package:invoice_generator/Helper/pdf_design.dart';
import 'package:invoice_generator/Models/Invoice_Model.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfHelper {
  static Future<void> generateInvoice(InvoiceModel invoiceData) async {
    final pdf = pw.Document(
      compress: false,
    );
    final bannerImg = await rootBundle.load('assets/images/invoice-banner.png');
    final watermarkImg =
        await rootBundle.load('assets/images/invoice-watermark.png');

    final banner = pw.MemoryImage(bannerImg.buffer.asUint8List());
    final watermark = pw.MemoryImage(watermarkImg.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pdfLayout(
            context,
            banner,
            watermark,
            invoiceData,
          );
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
