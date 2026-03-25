import 'package:invoice_generator/Models/Invoice_Model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('invoices.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> saveInvoice(InvoiceModel invoice) async {
    final db = await instance.database;
    return await db.insert('invoices', {
      'id': invoice.invoiceId,
      'data': invoice.toJson(),
      'createdAt': invoice.invoiceDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<InvoiceModel>> getAllInvoices() async {
    final db = await instance.database;
    final result = await db.query('invoices', orderBy: 'createdAt DESC');
    return result.map((json) => InvoiceModel.fromJson(json['data'] as String)).toList();
  }

  Future<int> deleteInvoice(String id) async {
    final db = await instance.database;
    return await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'invoices.db');
    await deleteDatabase(path);
    _database = null;
  }
}
