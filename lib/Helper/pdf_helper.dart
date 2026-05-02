import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:prime_invoice/Helper/database_service.dart';
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

    // pdf_watermark is a device-local UI pref — stays in SharedPreferences
    final pref = await SharedPreferences.getInstance();
    final showWatermark = pref.getBool("pdf_watermark") ?? true;

    // Load company profile from Supabase
    final profile = await DatabaseService.instance.getCompanyProfile();

    final bannerPath = profile.bannerPath;
    final watermarkPath = profile.watermarkPath;

    pw.MemoryImage? banner;
    pw.MemoryImage? watermark;

    try {
      if (bannerPath.isNotEmpty) {
        if (bannerPath.startsWith('http')) {
          final response = await http.get(Uri.parse(bannerPath));
          banner = pw.MemoryImage(response.bodyBytes);
        } else if (File(bannerPath).existsSync()) {
          final bannerBytes = await File(bannerPath).readAsBytes();
          banner = pw.MemoryImage(bannerBytes);
        } else {
          final bannerImg = await rootBundle.load('assets/images/invoice-banner.png');
          banner = pw.MemoryImage(bannerImg.buffer.asUint8List());
        }
      } else {
        final bannerImg = await rootBundle.load('assets/images/invoice-banner.png');
        banner = pw.MemoryImage(bannerImg.buffer.asUint8List());
      }
    } catch (e) {
      log("Error loading banner: $e");
    }

    try {
      if (watermarkPath.isNotEmpty) {
        if (watermarkPath.startsWith('http')) {
          final response = await http.get(Uri.parse(watermarkPath));
          watermark = pw.MemoryImage(response.bodyBytes);
        } else if (File(watermarkPath).existsSync()) {
          final watermarkBytes = await File(watermarkPath).readAsBytes();
          watermark = pw.MemoryImage(watermarkBytes);
        } else {
          final watermarkImg = await rootBundle.load('assets/images/invoice-watermark.png');
          watermark = pw.MemoryImage(watermarkImg.buffer.asUint8List());
        }
      } else {
        final watermarkImg = await rootBundle.load('assets/images/invoice-watermark.png');
        watermark = pw.MemoryImage(watermarkImg.buffer.asUint8List());
      }
    } catch (e) {
      log("Error loading watermark: $e");
    }

    // Build the profile map expected by pdfLayout
    final profileMap = {
      'biz_name': profile.name,
      'biz_phone': profile.phone,
      'biz_email': profile.email,
      'biz_gst': profile.gst,
      'biz_address': profile.address,
      'biz_bank': profile.bankDetails,
      'biz_terms': profile.terms,
      'biz_state': profile.state,
      'biz_declaration': profile.declaration,
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
            pdfLayout(context, banner, invoiceData, profileMap),
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
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Invoice: ${invoiceData.invoiceId}',
    );
  }
}
