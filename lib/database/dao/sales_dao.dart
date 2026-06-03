import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../tables/sales_table.dart';
import '../tables/sales_items_table.dart';
import '../../models/sale_model.dart';
import '../../models/sale_item_model.dart';

/// ─────────────────────────────────────────────────────────────
///  SALES DAO  –  lib/database/dao/sales_dao.dart
/// ─────────────────────────────────────────────────────────────
class SalesDao {
  Future<Database> get _db => DbHelper.instance.database;

  // ── INSERT SALE + ITEMS (transaction) ─────────────────────
  Future<int> insertSaleWithItems(
      SaleModel sale, List<SaleItemModel> items) async {
    final db = await _db;
    int saleId = 0;

    await db.transaction((txn) async {
      // Insert sale
      saleId = await txn.insert(SalesTable.tableName, sale.toMap());

      // Insert each item with the new saleId
      for (final item in items) {
        final itemMap = item.toMap();
        itemMap['sale_id'] = saleId;
        await txn.insert(SalesItemsTable.tableName, itemMap);
      }
    });
    return saleId;
  }

  // ── GET ALL SALES ──────────────────────────────────────────
  Future<List<SaleModel>> getAll({int limit = 50, int offset = 0}) async {
    final db   = await _db;
    final maps = await db.query(
      SalesTable.tableName,
      orderBy: '${SalesTable.createdAt} DESC',
      limit:   limit,
      offset:  offset,
    );
    return maps.map(SaleModel.fromMap).toList();
  }

  // ── GET BY DATE RANGE ──────────────────────────────────────
  Future<List<SaleModel>> getByDateRange(
      DateTime from, DateTime to) async {
    final db   = await _db;
    final maps = await db.query(
      SalesTable.tableName,
      where: '${SalesTable.createdAt} BETWEEN ? AND ?',
      whereArgs: [from.toIso8601String(), to.toIso8601String()],
      orderBy: '${SalesTable.createdAt} DESC',
    );
    return maps.map(SaleModel.fromMap).toList();
  }

  // ── GET TODAY'S SALES ──────────────────────────────────────
  Future<List<SaleModel>> getToday() async {
    final now   = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end   = start.add(const Duration(days: 1));
    return getByDateRange(start, end);
  }

  // ── GET BY INVOICE ID ──────────────────────────────────────
  Future<SaleModel?> getByInvoiceId(String invoiceId) async {
    final db   = await _db;
    final maps = await db.query(
      SalesTable.tableName,
      where: '${SalesTable.invoiceId} = ?',
      whereArgs: [invoiceId],
      limit: 1,
    );
    return maps.isEmpty ? null : SaleModel.fromMap(maps.first);
  }

  // ── GET ITEMS FOR A SALE ───────────────────────────────────
  Future<List<SaleItemModel>> getItemsForSale(int saleId) async {
    final db   = await _db;
    final maps = await db.query(
      SalesItemsTable.tableName,
      where: '${SalesItemsTable.saleId} = ?',
      whereArgs: [saleId],
    );
    return maps.map(SaleItemModel.fromMap).toList();
  }

  // ── UPDATE STATUS (e.g. refund) ────────────────────────────
  Future<int> updateStatus(int saleId, SaleStatus status) async {
    final db = await _db;
    return db.update(
      SalesTable.tableName,
      {'status': status.name},
      where: '${SalesTable.id} = ?',
      whereArgs: [saleId],
    );
  }

  // ── GENERATE NEXT INVOICE ID ───────────────────────────────
  Future<String> generateInvoiceId() async {
    final db  = await _db;
    final res = await db.rawQuery(
      'SELECT COUNT(*) FROM ${SalesTable.tableName}',
    );
    final count = (Sqflite.firstIntValue(res) ?? 0) + 1;
    final year  = DateTime.now().year;
    return 'INV-$year-${count.toString().padLeft(3, '0')}';
  }

  // ── TODAY'S TOTAL REVENUE ──────────────────────────────────
  Future<double> todayRevenue() async {
    final db  = await _db;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final end   = DateTime(now.year, now.month, now.day + 1).toIso8601String();
    final res = await db.rawQuery('''
      SELECT SUM(${SalesTable.total}) FROM ${SalesTable.tableName}
      WHERE ${SalesTable.createdAt} BETWEEN ? AND ?
      AND ${SalesTable.status} = 'completed'
    ''', [start, end]);
    return (res.first.values.first as num?)?.toDouble() ?? 0.0;
  }
}