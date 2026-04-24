import 'dart:developer';
import 'dart:io';
import 'package:prime_invoice/Helper/pdf_design.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';
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
    final pref = await SharedPreferences.getInstance();
    final showWatermark = pref.getBool("pdf_watermark") ?? true;

    final bannerPath = pref.getString("biz_banner") ?? "";
    final watermarkPath = pref.getString("biz_watermark") ?? "";

    pw.MemoryImage? banner;
    pw.MemoryImage? watermark;

    try {
      if (bannerPath.isNotEmpty && File(bannerPath).existsSync()) {
        final bannerBytes = await File(bannerPath).readAsBytes();
        banner = pw.MemoryImage(bannerBytes);
      } else {
        final bannerImg = await rootBundle.load(
          'assets/images/invoice-banner.png',
        );
        banner = pw.MemoryImage(bannerImg.buffer.asUint8List());
      }
    } catch (e) {
      log("Error loading banner: $e");
    }

    try {
      if (watermarkPath.isNotEmpty && File(watermarkPath).existsSync()) {
        final watermarkBytes = await File(watermarkPath).readAsBytes();
        watermark = pw.MemoryImage(watermarkBytes);
      } else {
        final watermarkImg = await rootBundle.load(
          'assets/images/invoice-watermark.png',
        );
        watermark = pw.MemoryImage(watermarkImg.buffer.asUint8List());
      }
    } catch (e) {
      log("Error loading watermark: $e");
    }

    final profile = {
      'biz_name': pref.getString("biz_name") ?? "",
      'biz_phone': pref.getString("biz_phone") ?? "",
      'biz_email': pref.getString("biz_email") ?? "",
      'biz_gst': pref.getString("biz_gst") ?? "",
      'biz_address': pref.getString("biz_address") ?? "",
      'biz_bank': pref.getString("biz_bank") ?? "",
      'biz_terms': pref.getString("biz_terms") ?? "",
      'biz_state': pref.getString("biz_state") ?? "",
      'biz_declaration': pref.getString("biz_declaration") ?? "",
    };

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      buildBackground: (context) {
        if (!showWatermark || watermark == null) return pw.SizedBox();
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
