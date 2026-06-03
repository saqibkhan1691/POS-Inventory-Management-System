/// ─────────────────────────────────────────────────────────────
///  SALE ITEM MODEL  –  lib/models/sale_item_model.dart
///  Each line item belonging to a sale
/// ─────────────────────────────────────────────────────────────
class SaleItemModel {
  final int?   id;
  final int    saleId;
  final int    productId;
  final String productName;
  final String barcode;
  final double unitPrice;
  final int    qty;
  final double total;

  const SaleItemModel({
    this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.barcode,
    required this.unitPrice,
    required this.qty,
    required this.total,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'sale_id':      saleId,
    'product_id':   productId,
    'product_name': productName,
    'barcode':      barcode,
    'unit_price':   unitPrice,
    'qty':          qty,
    'total':        total,
  };

  factory SaleItemModel.fromMap(Map<String, dynamic> map) => SaleItemModel(
    id:          map['id'] as int?,
    saleId:      map['sale_id'] as int,
    productId:   map['product_id'] as int,
    productName: map['product_name'] as String,
    barcode:     map['barcode'] as String,
    unitPrice:   (map['unit_price'] as num).toDouble(),
    qty:         map['qty'] as int,
    total:       (map['total'] as num).toDouble(),
  );
}