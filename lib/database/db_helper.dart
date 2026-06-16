import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables/product_table.dart';
import 'tables/sales_table.dart';
import 'tables/sales_items_table.dart';

/// ─────────────────────────────────────────────────────────────
///  DB HELPER  –  lib/database/db_helper.dart
///  Singleton. Opens/creates the SQLite database.
///  Handles versioning and migrations.
/// ─────────────────────────────────────────────────────────────
class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  static Database? _db;

  static const _dbName    = 'shree_sarees_pos.db';
  static const _dbVersion = 1;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate:  _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        // FK enforcement OFF — sale_items stores a snapshot (name/barcode/price)
        // so a product can be safely deleted even after it has been sold.
        await db.execute('PRAGMA foreign_keys = OFF');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create all tables
    await db.execute(ProductTable.createSql);
    await db.execute(SalesTable.createSql);
    await db.execute(SalesItemsTable.createSql);

    // Seed initial products
    final batch = db.batch();
    for (final row in ProductTable.seedData()) {
      batch.insert(ProductTable.tableName, row);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add migration logic here for future versions
    // e.g. if (oldVersion < 2) { await db.execute('ALTER TABLE...'); }
  }

  /// Close DB — call on app exit if needed
  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }

  /// Wipe and recreate — useful for dev/testing
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, _dbName);
    await deleteDatabase(path);
    _db = null;
    await database; // recreates
  }
}