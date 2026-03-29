import 'dart:io';
import 'package:flutter/material.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

    // 3. Open Database with safety timeout if possible
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE inventory (
          sku TEXT PRIMARY KEY,
          data TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE inventory (
        sku TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
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

  // --- CRUD Operations (Migrated from DatabaseHelper) ---

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
    // Note: No connection guard return here, let it try to query whatever DB is open
    // If it was unplugged mid-session, sqflite will handle errors or we'll detect via [isDriveConnected]
    await checkDriveAvailability();

    final db = await instance.database;
    final result = await db.query('invoices', orderBy: 'createdAt DESC');
    return result
        .map((json) => InvoiceModel.fromJson(json['data'] as String))
        .toList();
  }

  Future<int> deleteInvoice(String id) async {
    final db = await instance.database;
    return await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearDatabase() async {
    final db = await instance.database;
    await db.delete('invoices');
    await db.delete('inventory');
  }

  // --- Inventory CRUD ---

  Future<int> saveInventoryItem(Map<String, dynamic> item) async {
    final db = await instance.database;
    return await db.insert('inventory', {
      'sku': item['sku'],
      'data': item['data'], // JSON string
      'updatedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllInventoryRows() async {
    final db = await instance.database;
    return await db.query('inventory', orderBy: 'updatedAt DESC');
  }

  Future<int> deleteInventoryItem(String sku) async {
    final db = await instance.database;
    return await db.delete('inventory', where: 'sku = ?', whereArgs: [sku]);
  }
}
