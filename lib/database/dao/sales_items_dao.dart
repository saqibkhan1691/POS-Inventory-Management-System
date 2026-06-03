import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../tables/sales_items_table.dart';
import '../../models/sale_item_model.dart';

/// ─────────────────────────────────────────────────────────────
///  SALES ITEMS DAO  –  lib/database/dao/sales_items_dao.dart
/// ─────────────────────────────────────────────────────────────
class SalesItemsDao {
  Future<Database> get _db => DbHelper.instance.database;

  Future<int> insert(SaleItemModel item) async {
    final db = await _db;
    return db.insert(SalesItemsTable.tableName, item.toMap());
  }

  Future<List<SaleItemModel>> getBySaleId(int saleId) async {
    final db   = await _db;
    final maps = await db.query(
      SalesItemsTable.tableName,
      where: '${SalesItemsTable.saleId} = ?',
      whereArgs: [saleId],
    );
    return maps.map(SaleItemModel.fromMap).toList();
  }

  // Most sold products
  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5}) async {
    final db = await _db;
    return db.rawQuery('''
      SELECT ${SalesItemsTable.productName},
             ${SalesItemsTable.barcode},
             SUM(${SalesItemsTable.qty}) AS total_qty,
             SUM(${SalesItemsTable.total}) AS total_revenue
      FROM   ${SalesItemsTable.tableName}
      GROUP  BY ${SalesItemsTable.productId}
      ORDER  BY total_qty DESC
      LIMIT  $limit
    ''');
  }
}