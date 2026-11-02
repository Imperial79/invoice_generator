import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../Models/Customer_Model.dart';
import '../Resources/commons.dart';

class VcfHelper {
  /// Builds a standard vCard 3.0 string for the provided customer models.
  /// Formats name and phone according to RFC 2426 specification.
  static String generateVcf(List<CustomerModel> customers) {
    final buffer = StringBuffer();
    for (final customer in customers) {
      final name = customer.name.trim();
      final phone = customer.phone.trim();
      if (name.isEmpty && phone.isEmpty) continue;

      final displayName = name.isNotEmpty ? name : phone;
      buffer.write('BEGIN:VCARD\r\n');
      buffer.write('VERSION:3.0\r\n');
      buffer.write('FN:${_escape(displayName)}\r\n');
      buffer.write('N:;${_escape(displayName)};;;\r\n');

      if (phone.isNotEmpty) {
        final cleanPhone = phone.replaceAll(RegExp(r'[\r\n]'), '');
        buffer.write('TEL;TYPE=CELL:$cleanPhone\r\n');
      }

      if (customer.address.trim().isNotEmpty) {
        buffer.write('ADR;TYPE=WORK:;;${_escape(customer.address.trim())};;;;\r\n');
      }

      if (customer.clientType == 'Business') {
        buffer.write('ORG:${_escape(displayName)}\r\n');
      }

      buffer.write('END:VCARD\r\n');
    }
    return buffer.toString();
  }

  static String _escape(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll(';', r'\;')
        .replaceAll(',', r'\,')
        .replaceAll('\r\n', r'\n')
        .replaceAll('\r', r'\n')
        .replaceAll('\n', r'\n');
  }

  /// Writes contacts to a temporary .vcf file and returns the File.
  static Future<File> createTempVcfFile(
    List<CustomerModel> customers, {
    String? prefix,
  }) async {
    final vcfString = generateVcf(customers);
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${prefix ?? "contacts"}_$timestamp.vcf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(utf8.encode(vcfString), flush: true);
    return file;
  }

  /// Computes safe origin rectangle for iPad and macOS share sheet popovers.
  static Rect getShareOrigin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    final size = MediaQuery.sizeOf(context);
    return Rect.fromLTWH(0, 0, size.width, size.height / 2);
  }

  /// Triggers OS native share sheet for the VCF file.
  static Future<bool> shareVcf(
    BuildContext context,
    List<CustomerModel> customers, {
    Rect? sharePositionOrigin,
  }) async {
    try {
      final file = await createTempVcfFile(customers);
      final origin = sharePositionOrigin ?? getShareOrigin(context);
      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType: 'text/vcard',
            name: file.uri.pathSegments.last,
          ),
        ],
        text: 'Contacts (${customers.length} contacts)',
        sharePositionOrigin: origin,
      );
      return true;
    } catch (e) {
      log('VcfHelper.shareVcf Error: $e');
      if (context.mounted) {
        KSnackbar(context, message: 'Failed to share contacts: $e', error: true);
      }
      return false;
    }
  }

  /// Prompts file picker dialog to save the VCF file to the user's chosen directory.
  static Future<String?> saveVcfToDevice(
    BuildContext context,
    List<CustomerModel> customers,
  ) async {
    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final defaultFileName = 'contacts_$timestamp.vcf';
      final vcfString = generateVcf(customers);
      final bytes = utf8.encode(vcfString);

      final selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Contacts VCF',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['vcf'],
        bytes: kIsWeb ? bytes : null,
      );

      if (selectedPath != null) {
        String finalPath = selectedPath;
        if (!finalPath.toLowerCase().endsWith('.vcf')) {
          finalPath = '$finalPath.vcf';
        }
        final file = File(finalPath);
        await file.writeAsBytes(bytes, flush: true);
        if (context.mounted) {
          KSnackbar(
            context,
            message: 'Contacts saved to ${file.uri.pathSegments.last}',
          );
        }
        return finalPath;
      }
      return null;
    } catch (e) {
      log('VcfHelper.saveVcfToDevice Error: $e');
      if (context.mounted) {
        KSnackbar(context, message: 'Failed to save contacts: $e', error: true);
      }
      return null;
    }
  }

  /// Directly opens the .vcf file with the system default contacts application to import.
  static Future<bool> openInSystemContacts(
    BuildContext context,
    List<CustomerModel> customers,
  ) async {
    try {
      final file = await createTempVcfFile(customers);
      final result = await OpenFile.open(file.path, type: 'text/vcard');
      log('VcfHelper.openInSystemContacts: ${result.message}');
      if (result.type != ResultType.done && context.mounted) {
        KSnackbar(
          context,
          message: 'Unable to open Contacts app: ${result.message}',
          error: true,
        );
        return false;
      }
      return true;
    } catch (e) {
      log('VcfHelper.openInSystemContacts Error: $e');
      if (context.mounted) {
        KSnackbar(context, message: 'Failed to open contacts: $e', error: true);
      }
      return false;
    }
  }
}
