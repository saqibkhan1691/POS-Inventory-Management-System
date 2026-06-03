/// ─────────────────────────────────────────────────────────────
///  PRODUCT TABLE  –  lib/database/tables/product_table.dart
/// ─────────────────────────────────────────────────────────────
class ProductTable {
  static const tableName = 'products';

  static const id           = 'id';
  static const name         = 'name';
  static const barcode      = 'barcode';
  static const category     = 'category';
  static const brand        = 'brand';
  static const purchasePrice= 'purchase_price';
  static const sellingPrice = 'selling_price';
  static const taxRate      = 'tax_rate';
  static const stock        = 'stock';
  static const alertQty     = 'alert_qty';
  static const barcodeType  = 'barcode_type';
  static const description  = 'description';
  static const createdAt    = 'created_at';
  static const updatedAt    = 'updated_at';

  static const createSql = '''
    CREATE TABLE $tableName (
      $id             INTEGER PRIMARY KEY AUTOINCREMENT,
      $name           TEXT    NOT NULL,
      $barcode        TEXT    NOT NULL UNIQUE,
      $category       TEXT    NOT NULL,
      $brand          TEXT    NOT NULL DEFAULT 'In-House',
      $purchasePrice  REAL    NOT NULL DEFAULT 0,
      $sellingPrice   REAL    NOT NULL DEFAULT 0,
      $taxRate        REAL    NOT NULL DEFAULT 0.05,
      $stock          INTEGER NOT NULL DEFAULT 0,
      $alertQty       INTEGER NOT NULL DEFAULT 5,
      $barcodeType    TEXT    NOT NULL DEFAULT 'CODE128',
      $description    TEXT,
      $createdAt      TEXT    NOT NULL,
      $updatedAt      TEXT    NOT NULL
    )
  ''';

  // Seed data – real saree products
  static List<Map<String, dynamic>> seedData() {
    final now = DateTime.now().toIso8601String();
    return [
      {'name':'Banarasi Silk Saree - Red',  'barcode':'890123','category':'Silk Sarees',   'brand':'In-House','purchase_price':3000.0,'selling_price':4500.0,'tax_rate':0.05,'stock':12,'alert_qty':3,'barcode_type':'CODE128','description':null,'created_at':now,'updated_at':now},
      {'name':'Kanjeevaram Silk - Blue',     'barcode':'890124','category':'Silk Sarees',   'brand':'Nalli',   'purchase_price':4500.0,'selling_price':6200.0,'tax_rate':0.05,'stock':5, 'alert_qty':2,'barcode_type':'CODE128','description':null,'created_at':now,'updated_at':now},
      {'name':'Cotton Printed Saree',        'barcode':'890125','category':'Cotton Sarees', 'brand':'In-House','purchase_price':500.0, 'selling_price':850.0, 'tax_rate':0.05,'stock':40,'alert_qty':5,'barcode_type':'CODE128','description':null,'created_at':now,'updated_at':now},
      {'name':'Georgette Designer Saree',    'barcode':'890126','category':'Designer Wear', 'brand':'In-House','purchase_price':1400.0,'selling_price':2100.0,'tax_rate':0.12,'stock':0, 'alert_qty':3,'barcode_type':'CODE128','description':null,'created_at':now,'updated_at':now},
      {'name':'Mysore Silk Saree',           'barcode':'890127','category':'Silk Sarees',   'brand':'RMKV',    'purchase_price':2200.0,'selling_price':3200.0,'tax_rate':0.05,'stock':18,'alert_qty':4,'barcode_type':'CODE128','description':null,'created_at':now,'updated_at':now},
      {'name':'Linen Blend Daily Wear',      'barcode':'890128','category':'Cotton Sarees', 'brand':'In-House','purchase_price':800.0, 'selling_price':1200.0,'tax_rate':0.05,'stock':25,'alert_qty':5,'barcode_type':'CODE128','description':null,'created_at':now,'updated_at':now},
      {'name':'Pure Chanderi Silk',          'barcode':'890129','category':'Silk Sarees',   'brand':'Pothys',  'purchase_price':3800.0,'selling_price':5100.0,'tax_rate':0.05,'stock':3, 'alert_qty':2,'barcode_type':'CODE128','description':null,'created_at':now,'updated_at':now},
      {'name':'Embroidered Georgette',       'barcode':'890130','category':'Designer Wear', 'brand':'In-House','purchase_price':2500.0,'selling_price':3800.0,'tax_rate':0.12,'stock':7, 'alert_qty':3,'barcode_type':'CODE128','description':null,'created_at':now,'updated_at':now},
    ];
  }
}