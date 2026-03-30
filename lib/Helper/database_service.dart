import 'dart:io';
import 'package:flutter/material.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:prime_invoice/Models/Customer_Model.dart';

import 'package:prime_invoice/Models/Inventory_Model.dart';
import 'package:prime_invoice/Models/Metal_Rate_Model.dart';

class DatabaseService {
  // CONFIG: The name of your portable USB volume
  static const String driveName = "VB";
  static const String dbName = "invoice_data.db";

  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  // Track if drive is reachable
  static final ValueNotifier<bool> isDriveConnected = ValueNotifier(false);

  static final ValueNotifier<String> storageType = ValueNotifier(
    "Local Storage",
  );

  // Track if there's a permission/write error on the external drive
  static final ValueNotifier<bool> hasWriteIssue = ValueNotifier(false);

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path;
    final externalConnected = await checkDriveAvailability();

    try {
      if (externalConnected) {
        final dbFolder = Directory('/Volumes/$driveName/InvoiceAppData');
        if (!await dbFolder.exists()) {
          await dbFolder.create(recursive: true);
        }
        path = join(dbFolder.path, dbName);
        storageType.value = "Portable Drive";
        isDriveConnected.value = true;
        hasWriteIssue.value = false;
        debugPrint("Using External Storage: $path");
      } else {
        throw PathNotFoundException("", const OSError("", 2));
      }
    } catch (e) {
      debugPrint("External DB Init Failed: $e. Falling back to Local Storage.");
      if (externalConnected) {
        hasWriteIssue.value = true;
      }

      // Fallback to local
      try {
        final internalPath = await getDatabasesPath();
        path = join(internalPath, dbName);
        storageType.value = "Local Storage";
      } catch (inner) {
        debugPrint("CRITICAL: Local storage path failed: $inner");
        // Final ultimate fallback path
        path = dbName;
      }
    }

    // 7. Open Database with version 10
    return await openDatabase(
      path,
      version: 10,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS invoices (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        address TEXT,
        gst TEXT,
        pan TEXT,
        aadhaar TEXT,
        clientType TEXT NOT NULL DEFAULT 'Customer'
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sku TEXT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        weight REAL NOT NULL,
        purity TEXT NOT NULL,
        makingCharges REAL NOT NULL,
        makingChargesType TEXT NOT NULL DEFAULT 'Fixed',
        stock REAL NOT NULL,
        minStockAlert REAL NOT NULL DEFAULT 2
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS metal_rates (
        metalType TEXT NOT NULL,
        purity TEXT NOT NULL,
        ratePer10g REAL NOT NULL,
        PRIMARY KEY (metalType, purity)
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS customers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL UNIQUE,
          address TEXT,
          gst TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS inventory (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sku TEXT,
          name TEXT NOT NULL,
          category TEXT NOT NULL,
          weight REAL NOT NULL,
          purity TEXT NOT NULL,
          makingCharges REAL NOT NULL,
          stock REAL NOT NULL,
          minStockAlert REAL NOT NULL DEFAULT 2
        )
      ''');
    }

    // Schema Repair Logic
    if (oldVersion < 8) {
      // 1. Repair Customers
      final customerCols = ["pan", "aadhaar"];
      for (var col in customerCols) {
        try {
          await db.execute('ALTER TABLE customers ADD COLUMN $col TEXT');
        } catch (_) {}
      }

      // 2. Repair Inventory
      final inventoryCols = {
        "sku": "TEXT",
        "name": "TEXT NOT NULL DEFAULT ''",
        "category": "TEXT NOT NULL DEFAULT 'Gold'",
        "weight": "REAL NOT NULL DEFAULT 0",
        "purity": "TEXT NOT NULL DEFAULT ''",
        "makingCharges": "REAL NOT NULL DEFAULT 0",
        "makingChargesType": "TEXT NOT NULL DEFAULT 'Fixed'",
        "stock": "REAL NOT NULL DEFAULT 0",
        "minStockAlert": "REAL NOT NULL DEFAULT 2",
      };

      for (var entry in inventoryCols.entries) {
        try {
          await db.execute(
            'ALTER TABLE inventory ADD COLUMN ${entry.key} ${entry.value}',
          );
        } catch (_) {}
      }
    }

    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS metal_rates (
          metalType TEXT NOT NULL,
          purity TEXT NOT NULL,
          ratePer10g REAL NOT NULL,
          PRIMARY KEY (metalType, purity)
        )
      ''');
    }

    if (oldVersion < 10) {
      try {
        await db.execute(
          "ALTER TABLE customers ADD COLUMN clientType TEXT NOT NULL DEFAULT 'Customer'",
        );
      } catch (_) {}
    }
  }

  // Verify if the directory exists in /Volumes/
  Future<bool> checkDriveAvailability() async {
    if (!Platform.isMacOS) return true; // Only mac handles /Volumes/ like this

    final drive = Directory('/Volumes/$driveName');
    final connected = await drive.exists();
    if (isDriveConnected.value != connected) {
      isDriveConnected.value = connected;
    }
    return connected;
  }

  // Safe Shutdown helper
  Future<void> safeShutdown() async {
    if (_database != null) {
      debugPrint("Closing database connection...");
      await _database!.close();
      _database = null;
    }
  }

  // --- CRUD Operations ---

  // INVOICES

  Future<int> saveInvoice(InvoiceModel invoice) async {
    final db = await instance.database;
    return await db.insert('invoices', {
      'id': invoice.invoiceId,
      'data': invoice.toJson(),
      'createdAt':
          invoice.invoiceDate?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<InvoiceModel>> getAllInvoices() async {
    await checkDriveAvailability();
    final db = await instance.database;
    final result = await db.query('invoices', orderBy: 'createdAt DESC');
    return result
        .map((json) => InvoiceModel.fromJson(json['data'] as String))
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

  Future<int> deleteInvoice(String id) async {
    final db = await instance.database;
    return await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  // CUSTOMERS

  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    final db = await instance.database;
    final result = await db.query(
      'customers',
      where: 'phone = ?',
      whereArgs: [phone],
    );
    if (result.isNotEmpty) {
      return CustomerModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> saveCustomer(CustomerModel customer) async {
    final db = await instance.database;
    return await db.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CustomerModel>> getAllCustomers() async {
    final db = await instance.database;
    final result = await db.query('customers', orderBy: 'name ASC');
    return result.map((json) => CustomerModel.fromMap(json)).toList();
  }

  Future<int> deleteCustomer(int id) async {
    final db = await instance.database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // INVENTORY

  Future<int> saveInventoryItem(InventoryModel item) async {
    final db = await instance.database;
    return await db.insert(
      'inventory',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<InventoryModel>> getAllInventory() async {
    final db = await instance.database;
    final result = await db.query(
      'inventory',
      orderBy: 'category ASC, name ASC',
    );
    return result.map((json) => InventoryModel.fromMap(json)).toList();
  }

  Future<int> deleteInventoryItem(int id) async {
    final db = await instance.database;
    return await db.delete('inventory', where: 'id = ?', whereArgs: [id]);
  }

  // System Helpers

  Future<void> clearDatabase() async {
    final db = await instance.database;
    await db.delete('invoices');
    await db.delete('customers');
    await db.delete('inventory');
    await db.delete('metal_rates');
  }

  // METAL RATES

  Future<int> saveMetalRate(String metal, String purity, double rate) async {
    final db = await instance.database;
    return await db.insert(
      'metal_rates',
      {'metalType': metal, 'purity': purity, 'ratePer10g': rate},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MetalRateModel>> getAllMetalRates() async {
    final db = await instance.database;
    final res = await db.query('metal_rates');
    return res.map((m) => MetalRateModel.fromMap(m)).toList();
  }

  Future<double?> getMetalRate(String metal, String purity) async {
    final db = await instance.database;
    final result = await db.query(
      'metal_rates',
      where: 'metalType = ? AND purity = ?',
      whereArgs: [metal, purity],
    );
    if (result.isNotEmpty) {
      return (result.first['ratePer10g'] as num).toDouble();
    }
    return null;
  }
}
