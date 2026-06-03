/// ─────────────────────────────────────────────────────────────
///  SALES TABLE  –  lib/database/tables/sales_table.dart
/// ─────────────────────────────────────────────────────────────
class SalesTable {
  static const tableName = 'sales';

  static const id            = 'id';
  static const invoiceId     = 'invoice_id';
  static const customer      = 'customer';
  static const subtotal      = 'subtotal';
  static const discount      = 'discount';
  static const tax           = 'tax';
  static const total         = 'total';
  static const paymentMethod = 'payment_method';
  static const status        = 'status';
  static const createdAt     = 'created_at';

  static const createSql = '''
    CREATE TABLE $tableName (
      $id             INTEGER PRIMARY KEY AUTOINCREMENT,
      $invoiceId      TEXT    NOT NULL UNIQUE,
      $customer       TEXT    NOT NULL DEFAULT 'Walk-in Customer',
      $subtotal       REAL    NOT NULL DEFAULT 0,
      $discount       REAL    NOT NULL DEFAULT 0,
      $tax            REAL    NOT NULL DEFAULT 0,
      $total          REAL    NOT NULL DEFAULT 0,
      $paymentMethod  TEXT    NOT NULL DEFAULT 'cash',
      $status         TEXT    NOT NULL DEFAULT 'completed',
      $createdAt      TEXT    NOT NULL
    )
  ''';
}