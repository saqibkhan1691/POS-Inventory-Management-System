/// ─────────────────────────────────────────────────────────────
///  SETTINGS TABLE  –  lib/database/tables/settings_table.dart
/// ─────────────────────────────────────────────────────────────
class SettingsTable {
  static const tableName = 'settings';

  // Each user's settings stored by userId
  static const id             = 'id';
  static const userId         = 'user_id';  // ← per-user isolation
  static const shopName       = 'shop_name';
  static const ownerName      = 'owner_name';
  static const phone          = 'phone';
  static const address        = 'address';
  static const gstNumber      = 'gst_number';
  static const currency       = 'currency';
  static const taxPercent     = 'tax_percent';
  static const discountEnabled = 'discount_enabled';
  static const autoRoundOff   = 'auto_round_off';
  static const invoiceType    = 'invoice_type';
  static const trackStock     = 'track_stock';
  static const autoBarcode    = 'auto_barcode';
  static const lowStockAlert  = 'low_stock_alert';
  static const defaultUnit    = 'default_unit';
  static const autoSync       = 'auto_sync';
  static const wifiOnly       = 'wifi_only';
  static const autoBackup     = 'auto_backup';
  static const syncFrequency  = 'sync_frequency';
  static const printerName    = 'printer_name';
  static const paperSize      = 'paper_size';
  static const autoPrint      = 'auto_print';
  static const language       = 'language';
  static const dateFormat     = 'date_format';
  static const timeFormat     = 'time_format';
  static const themeMode      = 'theme_mode';
  static const updatedAt      = 'updated_at';

  static const createSql = '''
    CREATE TABLE $tableName (
      $id               INTEGER PRIMARY KEY AUTOINCREMENT,
      $userId           TEXT    NOT NULL DEFAULT 'default',
      $shopName         TEXT    NOT NULL DEFAULT 'My Shop',
      $ownerName        TEXT    NOT NULL DEFAULT 'Admin',
      $phone            TEXT    NOT NULL DEFAULT '',
      $address          TEXT    NOT NULL DEFAULT '',
      $gstNumber        TEXT    NOT NULL DEFAULT '',
      $currency         TEXT    NOT NULL DEFAULT '₹ (INR) - Indian Rupee',
      $taxPercent       REAL    NOT NULL DEFAULT 5.0,
      $discountEnabled  INTEGER NOT NULL DEFAULT 1,
      $autoRoundOff     INTEGER NOT NULL DEFAULT 1,
      $invoiceType      TEXT    NOT NULL DEFAULT 'thermal',
      $trackStock       INTEGER NOT NULL DEFAULT 1,
      $autoBarcode      INTEGER NOT NULL DEFAULT 1,
      $lowStockAlert    INTEGER NOT NULL DEFAULT 10,
      $defaultUnit      TEXT    NOT NULL DEFAULT 'Pieces (pcs)',
      $autoSync         INTEGER NOT NULL DEFAULT 1,
      $wifiOnly         INTEGER NOT NULL DEFAULT 1,
      $autoBackup       INTEGER NOT NULL DEFAULT 0,
      $syncFrequency    TEXT    NOT NULL DEFAULT 'Every 5 minutes',
      $printerName      TEXT    NOT NULL DEFAULT 'No Printer',
      $paperSize        TEXT    NOT NULL DEFAULT '80mm (Standard Receipt)',
      $autoPrint        INTEGER NOT NULL DEFAULT 1,
      $language         TEXT    NOT NULL DEFAULT 'English',
      $dateFormat       TEXT    NOT NULL DEFAULT 'DD/MM/YYYY',
      $timeFormat       TEXT    NOT NULL DEFAULT '12-hour (AM/PM)',
      $themeMode        TEXT    NOT NULL DEFAULT 'light',
      $updatedAt        TEXT    NOT NULL,
      UNIQUE($userId)
    )
  ''';
}