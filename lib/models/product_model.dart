/// ─────────────────────────────────────────────────────────────
///  PRODUCT MODEL  –  lib/models/product_model.dart
/// ─────────────────────────────────────────────────────────────
class ProductModel {
  final int?   id;
  final String name;
  final String barcode;
  final String category;
  final String brand;
  final double purchasePrice;
  final double sellingPrice;
  final double taxRate;
  final int    stock;
  final int    alertQty;
  final String barcodeType;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    this.id,
    required this.name,
    required this.barcode,
    required this.category,
    this.brand        = 'In-House',
    required this.purchasePrice,
    required this.sellingPrice,
    this.taxRate      = 0.05,
    this.stock        = 0,
    this.alertQty     = 5,
    this.barcodeType  = 'CODE128',
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name':           name,
    'barcode':        barcode,
    'category':       category,
    'brand':          brand,
    'purchase_price': purchasePrice,
    'selling_price':  sellingPrice,
    'tax_rate':       taxRate,
    'stock':          stock,
    'alert_qty':      alertQty,
    'barcode_type':   barcodeType,
    'description':    description,
    'created_at':     createdAt.toIso8601String(),
    'updated_at':     updatedAt.toIso8601String(),
  };

  factory ProductModel.fromMap(Map<String, dynamic> map) => ProductModel(
    id:            map['id'] as int?,
    name:          map['name'] as String,
    barcode:       map['barcode'] as String,
    category:      map['category'] as String,
    brand:         map['brand'] as String? ?? 'In-House',
    purchasePrice: (map['purchase_price'] as num).toDouble(),
    sellingPrice:  (map['selling_price'] as num).toDouble(),
    taxRate:       (map['tax_rate'] as num?)?.toDouble() ?? 0.05,
    stock:         map['stock'] as int? ?? 0,
    alertQty:      map['alert_qty'] as int? ?? 5,
    barcodeType:   map['barcode_type'] as String? ?? 'CODE128',
    description:   map['description'] as String?,
    createdAt:     DateTime.parse(map['created_at'] as String),
    updatedAt:     DateTime.parse(map['updated_at'] as String),
  );

  ProductModel copyWith({
    int? id, String? name, String? barcode, String? category,
    String? brand, double? purchasePrice, double? sellingPrice,
    double? taxRate, int? stock, int? alertQty, String? barcodeType,
    String? description, DateTime? createdAt, DateTime? updatedAt,
  }) => ProductModel(
    id:            id ?? this.id,
    name:          name ?? this.name,
    barcode:       barcode ?? this.barcode,
    category:      category ?? this.category,
    brand:         brand ?? this.brand,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    sellingPrice:  sellingPrice ?? this.sellingPrice,
    taxRate:       taxRate ?? this.taxRate,
    stock:         stock ?? this.stock,
    alertQty:      alertQty ?? this.alertQty,
    barcodeType:   barcodeType ?? this.barcodeType,
    description:   description ?? this.description,
    createdAt:     createdAt ?? this.createdAt,
    updatedAt:     updatedAt ?? this.updatedAt,
  );
}