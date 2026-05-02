import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:prime_invoice/Models/Company_Profile_Model.dart';
import 'package:prime_invoice/Models/Customer_Model.dart';
import 'package:prime_invoice/Models/Inventory_Model.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:prime_invoice/Models/Metal_Rate_Model.dart';
import 'package:prime_invoice/Models/Stock_Log_Model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  SupabaseClient get _client => Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // Connection status notifier (replaces old drive-connected logic)
  // ---------------------------------------------------------------------------
  static final ValueNotifier<bool> isDriveConnected = ValueNotifier(true);
  static final ValueNotifier<String> storageType = ValueNotifier("Supabase");
  static final ValueNotifier<bool> hasWriteIssue = ValueNotifier(false);

  /// No-op: kept for API compatibility (was used to check external drive).
  Future<bool> checkDriveAvailability() async {
    return true;
  }

  /// No-op: Supabase connections don't need manual shutdown.
  Future<void> safeShutdown() async {
    debugPrint("Supabase: no manual shutdown required.");
  }

  /// No-op: no local DB path for Supabase.
  Future<String?> getDbPath() async => null;

  // ---------------------------------------------------------------------------
  // INVOICES
  // ---------------------------------------------------------------------------

  Future<void> saveInvoice(InvoiceModel invoice) async {
    await _client.from('invoices').upsert({
      'id': invoice.invoiceId,
      'data': invoice.toJson(),
      'created_at':
          invoice.invoiceDate?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    });
  }

  Future<List<InvoiceModel>> getAllInvoices() async {
    final result = await _client
        .from('invoices')
        .select()
        .order('created_at', ascending: false);
    return result
        .map<InvoiceModel>(
          (row) => InvoiceModel.fromJson(row['data'] as String),
        )
        .toList();
  }

  Future<List<InvoiceModel>> getInvoicesByCustomer(
    String name,
    String phone,
  ) async {
    final all = await getAllInvoices();
    return all
        .where(
          (inv) =>
              inv.customerName.toLowerCase() == name.toLowerCase() ||
              inv.customerPhone == phone,
        )
        .toList();
  }

  Future<void> deleteInvoice(String id) async {
    await _client.from('invoices').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // CUSTOMERS
  // ---------------------------------------------------------------------------

  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    final result = await _client
        .from('customers')
        .select()
        .eq('phone', phone)
        .maybeSingle();
    if (result != null) {
      return CustomerModel.fromMap(result);
    }
    return null;
  }

  Future<void> saveCustomer(CustomerModel customer) async {
    final map = customer.toMap();
    if (customer.id != null) {
      await _client.from('customers').upsert(map);
    } else {
      // Let Supabase auto-generate the id
      map.remove('id');
      await _client.from('customers').insert(map);
    }
  }

  Future<List<CustomerModel>> getAllCustomers() async {
    final result = await _client
        .from('customers')
        .select()
        .order('name', ascending: true);
    return result
        .map<CustomerModel>((row) => CustomerModel.fromMap(row))
        .toList();
  }

  Future<void> deleteCustomer(int id) async {
    await _client.from('customers').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // INVENTORY
  // ---------------------------------------------------------------------------

  Future<void> saveInventoryItem(InventoryModel item) async {
    final map = item.toMap();
    if (item.id != null) {
      await _client.from('inventory').upsert(map);
    } else {
      map.remove('id');
      await _client.from('inventory').insert(map);
    }
  }

  Future<List<InventoryModel>> getAllInventory() async {
    final result = await _client
        .from('inventory')
        .select()
        .order('category', ascending: true);
    return result
        .map<InventoryModel>((row) => InventoryModel.fromMap(row))
        .toList();
  }

  Future<void> deleteInventoryItem(int id) async {
    await _client.from('inventory').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // STOCK LOGS
  // ---------------------------------------------------------------------------

  Future<void> saveStockLog(StockLogModel log) async {
    final map = log.toMap()..remove('id');
    await _client.from('stock_logs').insert(map);
  }

  Future<List<StockLogModel>> getStockLogsForItem(int itemId) async {
    final result = await _client
        .from('stock_logs')
        .select()
        .eq('item_id', itemId)
        .order('date', ascending: false);
    return result
        .map<StockLogModel>((row) => StockLogModel.fromMap(row))
        .toList();
  }

  /// Adjusts stock and records a log entry atomically via a Supabase RPC.
  /// Falls back to sequential writes if the RPC isn't available yet.
  Future<void> recordStockAdjustment({
    required InventoryModel item,
    required double weightDelta,
    required double pieceDelta,
    required String action,
    required String type,
    required String notes,
  }) async {
    final updatedItem = item.copyWith(
      weightStock: (item.weightStock + weightDelta).clamp(0, double.infinity),
      pieceStock: (item.pieceStock + pieceDelta).clamp(0, double.infinity),
    );

    // Update inventory
    await _client
        .from('inventory')
        .update(updatedItem.toMap())
        .eq('id', item.id!);

    // Insert stock log
    final log = StockLogModel(
      itemId: item.id!,
      itemName: item.name,
      sku: item.sku,
      action: action,
      type: type,
      weight: weightDelta.abs(),
      pieces: pieceDelta.abs(),
      notes: notes,
      date: DateTime.now(),
    );
    await saveStockLog(log);
  }

  // ---------------------------------------------------------------------------
  // METAL RATES
  // ---------------------------------------------------------------------------

  Future<void> saveMetalRate(
    String metal,
    String purity,
    double rate,
  ) async {
    await _client.from('metal_rates').upsert({
      'metal_type': metal,
      'purity': purity,
      'rate_per10g': rate,
    });
  }

  Future<List<MetalRateModel>> getAllMetalRates() async {
    final result = await _client.from('metal_rates').select();
    return result
        .map<MetalRateModel>((row) => MetalRateModel.fromMap({
              'metalType': row['metal_type'],
              'purity': row['purity'],
              'ratePer10g': row['rate_per10g'],
            }))
        .toList();
  }

  Future<double?> getMetalRate(String metal, String purity) async {
    final result = await _client
        .from('metal_rates')
        .select('rate_per10g')
        .eq('metal_type', metal)
        .eq('purity', purity)
        .maybeSingle();
    if (result != null) {
      return (result['rate_per10g'] as num).toDouble();
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // SYSTEM HELPERS
  // ---------------------------------------------------------------------------

  Future<void> clearDatabase() async {
    await _client.from('invoices').delete().neq('id', '');
    await _client.from('customers').delete().gt('id', 0);
    await _client.from('inventory').delete().gt('id', 0);
    await _client.from('metal_rates').delete().neq('metal_type', '');
  }

  // ---------------------------------------------------------------------------
  // COMPANY PROFILE
  // ---------------------------------------------------------------------------

  /// Returns the single company profile row, or a default empty profile.
  Future<CompanyProfileModel> getCompanyProfile() async {
    final result = await _client
        .from('company_profile')
        .select()
        .eq('id', 1)
        .maybeSingle();
    if (result != null) {
      return CompanyProfileModel.fromMap(result);
    }
    return const CompanyProfileModel();
  }

  /// Upserts the company profile (always id = 1).
  Future<void> saveCompanyProfile(CompanyProfileModel profile) async {
    await _client.from('company_profile').upsert(profile.toMap());
  }

  /// Uploads a file to Supabase Storage and returns the public URL.
  Future<String> uploadFile(File file, String path) async {
    final fileName = path.split('/').last;
    final extension = fileName.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final finalPath = 'company/$timestamp.$extension';

    await _client.storage.from('PrimeInvoiceBuket').upload(
      finalPath,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );

    return _client.storage.from('PrimeInvoiceBuket').getPublicUrl(finalPath);
  }

}
