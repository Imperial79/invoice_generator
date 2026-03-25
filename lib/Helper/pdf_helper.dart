import 'dart:developer';
import 'dart:io';
import 'package:invoice_generator/Helper/pdf_design.dart';
import 'package:invoice_generator/Models/Invoice_Model.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfHelper {
  static Future<File> _buildPdfFile(InvoiceModel invoiceData) async {
    final pdf = pw.Document(compress: false);
    final bannerImg = await rootBundle.load('assets/images/invoice-banner.png');
    final watermarkImg = await rootBundle.load('assets/images/invoice-watermark.png');

    final banner = pw.MemoryImage(bannerImg.buffer.asUint8List());
    final watermark = pw.MemoryImage(watermarkImg.buffer.asUint8List());

    final pref = await SharedPreferences.getInstance();
    final showWatermark = pref.getBool("pdf_watermark") ?? true;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) =>
            pdfLayout(context, banner, watermark, invoiceData, showWatermark),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${invoiceData.invoiceId}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<void> generateInvoice(InvoiceModel invoiceData) async {
    final file = await _buildPdfFile(invoiceData);
    log("PDF Saved to ${file.path}");
    final result = await OpenFile.open(file.path);
    log("OpenFile result: ${result.message}");
  }

  static Future<void> shareInvoice(InvoiceModel invoiceData) async {
    final file = await _buildPdfFile(invoiceData);
    await Share.shareXFiles([XFile(file.path)], text: 'Invoice: ${invoiceData.invoiceId}');
  }
}
