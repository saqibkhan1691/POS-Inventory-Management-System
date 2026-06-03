/// ─────────────────────────────────────────────────────────────
///  SALES ITEMS TABLE  –  lib/database/tables/sales_items_table.dart
/// ─────────────────────────────────────────────────────────────
class SalesItemsTable {
  static const tableName = 'sale_items';

  static const id          = 'id';
  static const saleId      = 'sale_id';
  static const productId   = 'product_id';
  static const productName = 'product_name';
  static const barcode     = 'barcode';
  static const unitPrice   = 'unit_price';
  static const qty         = 'qty';
  static const total       = 'total';

  static const createSql = '''
    CREATE TABLE $tableName (
      $id           INTEGER PRIMARY KEY AUTOINCREMENT,
      $saleId       INTEGER NOT NULL,
      $productId    INTEGER NOT NULL,
      $productName  TEXT    NOT NULL,
      $barcode      TEXT    NOT NULL,
      $unitPrice    REAL    NOT NULL,
      $qty          INTEGER NOT NULL DEFAULT 1,
      $total        REAL    NOT NULL,
      FOREIGN KEY ($saleId)    REFERENCES sales(id)    ON DELETE CASCADE,
      FOREIGN KEY ($productId) REFERENCES products(id) ON DELETE RESTRICT
    )
  ''';
}