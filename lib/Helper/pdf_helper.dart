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
    final watermarkImg = await rootBundle.load(
      'assets/images/invoice-watermark.png',
    );

    final banner = pw.MemoryImage(bannerImg.buffer.asUint8List());
    final watermark = pw.MemoryImage(watermarkImg.buffer.asUint8List());

    final pref = await SharedPreferences.getInstance();
    final showWatermark = pref.getBool("pdf_watermark") ?? true;

    final profile = {
      'biz_name': pref.getString("biz_name") ?? "Imperial Studio",
      'biz_phone': pref.getString("biz_phone") ?? "",
      'biz_email': pref.getString("biz_email") ?? "",
      'biz_gst': pref.getString("biz_gst") ?? "19APDPV5128C1ZU",
      'biz_address':
          pref.getString("biz_address") ?? "Arrah More, Durgapur - 713212",
      'biz_bank':
          pref.getString("biz_bank") ??
          "BANK DETAILS - SBI BANK, DURGAPUR SEN MARKET - A/C - 8718927918219871, IFSC - AKSLJASKLAAS\nSOUTH INDIAN BANK - ABC ROAD, - A/C - 8718927918219871, IFSC - AKSLJASKLAAS",
      'biz_terms':
          pref.getString("biz_terms") ??
          "E. & O.E.\n1. Payments via cheque are subject to verification.\n2. No returns or exchanges for sold goods.\n3. 18% interest on overdue payments.\n4. Disputes are under 'West Bengal' jurisdiction.\n5. Report invoice errors within 7 days.",
      'biz_state': pref.getString("biz_state") ?? "West Bengal (19)",
    };

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      buildBackground: (context) {
        if (!showWatermark) return pw.SizedBox();
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Opacity(
            opacity: 1,
            child: pw.Center(child: pw.Image(watermark, width: 400)),
          ),
        );
      },
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (pw.Context context) =>
            pdfLayout(context, banner, invoiceData, profile),
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
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Invoice: ${invoiceData.invoiceId}');
  }
}
