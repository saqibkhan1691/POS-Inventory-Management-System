import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables/product_table.dart';
import 'tables/sales_table.dart';
import 'tables/sales_items_table.dart';
import 'tables/settings_table.dart';

/// ─────────────────────────────────────────────────────────────
///  DB HELPER  –  lib/database/db_helper.dart
/// ─────────────────────────────────────────────────────────────
class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  static Database? _db;

  static const _dbName    = 'shree_sarees_pos.db';
  static const _dbVersion = 2; // bumped to 2 for settings table migration

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
      onCreate:    _onCreate,
      onUpgrade:   _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = OFF');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(ProductTable.createSql);
    await db.execute(SalesTable.createSql);
    await db.execute(SalesItemsTable.createSql);
    await db.execute(SettingsTable.createSql);  // ← new

    // Seed products
    final batch = db.batch();
    for (final row in ProductTable.seedData()) {
      batch.insert(ProductTable.tableName, row);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Version 1 → 2: add settings table
    if (oldVersion < 2) {
      await db.execute(SettingsTable.createSql);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, _dbName);
    await deleteDatabase(path);
    _db = null;
    await database;
  }
}