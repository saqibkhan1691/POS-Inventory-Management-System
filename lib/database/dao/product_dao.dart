import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../tables/product_table.dart';
import '../../models/product_model.dart';

/// ─────────────────────────────────────────────────────────────
///  PRODUCT DAO  –  lib/database/dao/product_dao.dart
///  Direct SQLite operations for products table
/// ─────────────────────────────────────────────────────────────
class ProductDao {
  Future<Database> get _db => DbHelper.instance.database;

  // ── INSERT ─────────────────────────────────────────────────
  Future<int> insert(ProductModel product) async {
    final db = await _db;
    return db.insert(
      ProductTable.tableName,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── GET ALL ────────────────────────────────────────────────
  Future<List<ProductModel>> getAll() async {
    final db   = await _db;
    final maps = await db.query(
      ProductTable.tableName,
      orderBy: '${ProductTable.name} ASC',
    );
    return maps.map(ProductModel.fromMap).toList();
  }

  // ── GET BY ID ──────────────────────────────────────────────
  Future<ProductModel?> getById(int id) async {
    final db   = await _db;
    final maps = await db.query(
      ProductTable.tableName,
      where: '${ProductTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isEmpty ? null : ProductModel.fromMap(maps.first);
  }

  // ── GET BY BARCODE ─────────────────────────────────────────
  Future<ProductModel?> getByBarcode(String barcode) async {
    final db   = await _db;
    final maps = await db.query(
      ProductTable.tableName,
      where: '${ProductTable.barcode} = ?',
      whereArgs: [barcode],
      limit: 1,
    );
    return maps.isEmpty ? null : ProductModel.fromMap(maps.first);
  }

  // ── SEARCH ─────────────────────────────────────────────────
  Future<List<ProductModel>> search(String query) async {
    final db   = await _db;
    final q    = '%$query%';
    final maps = await db.query(
      ProductTable.tableName,
      where: '${ProductTable.name} LIKE ? OR ${ProductTable.barcode} LIKE ? OR ${ProductTable.category} LIKE ?',
      whereArgs: [q, q, q],
      orderBy: '${ProductTable.name} ASC',
    );
    return maps.map(ProductModel.fromMap).toList();
  }

  // ── FILTER BY CATEGORY ─────────────────────────────────────
  Future<List<ProductModel>> getByCategory(String category) async {
    final db   = await _db;
    final maps = await db.query(
      ProductTable.tableName,
      where: '${ProductTable.category} = ?',
      whereArgs: [category],
      orderBy: '${ProductTable.name} ASC',
    );
    return maps.map(ProductModel.fromMap).toList();
  }

  // ── GET LOW STOCK ──────────────────────────────────────────
  Future<List<ProductModel>> getLowStock() async {
    final db   = await _db;
    final maps = await db.rawQuery('''
      SELECT * FROM ${ProductTable.tableName}
      WHERE ${ProductTable.stock} <= ${ProductTable.alertQty}
      ORDER BY ${ProductTable.stock} ASC
    ''');
    return maps.map(ProductModel.fromMap).toList();
  }

  // ── GET DISTINCT CATEGORIES ────────────────────────────────
  Future<List<String>> getCategories() async {
    final db   = await _db;
    final maps = await db.rawQuery(
      'SELECT DISTINCT ${ProductTable.category} FROM ${ProductTable.tableName} ORDER BY ${ProductTable.category}',
    );
    return maps.map((m) => m[ProductTable.category] as String).toList();
  }

  // ── UPDATE ─────────────────────────────────────────────────
  Future<int> update(ProductModel product) async {
    final db = await _db;
    return db.update(
      ProductTable.tableName,
      product.copyWith(updatedAt: DateTime.now()).toMap(),
      where: '${ProductTable.id} = ?',
      whereArgs: [product.id],
    );
  }

  // ── UPDATE STOCK ───────────────────────────────────────────
  /// Decrease stock after a sale. Pass negative qty to decrease.
  Future<void> adjustStock(int productId, int qtyChange) async {
    final db = await _db;
    await db.rawUpdate('''
      UPDATE ${ProductTable.tableName}
      SET ${ProductTable.stock}     = ${ProductTable.stock} + ?,
          ${ProductTable.updatedAt} = ?
      WHERE ${ProductTable.id} = ?
    ''', [qtyChange, DateTime.now().toIso8601String(), productId]);
  }

  // ── DELETE ─────────────────────────────────────────────────
  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete(
      ProductTable.tableName,
      where: '${ProductTable.id} = ?',
      whereArgs: [id],
    );
  }

  // ── COUNT ──────────────────────────────────────────────────
  Future<int> count() async {
    final db  = await _db;
    final res = await db.rawQuery('SELECT COUNT(*) FROM ${ProductTable.tableName}');
    return Sqflite.firstIntValue(res) ?? 0;
  }
}