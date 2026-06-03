/// ─────────────────────────────────────────────────────────────
///  SALE MODEL  –  lib/models/sale_model.dart
///  Represents one complete bill/transaction
/// ─────────────────────────────────────────────────────────────
enum PaymentMethod { cash, upi, card }
enum SaleStatus    { completed, refunded, pending }

class SaleModel {
  final int?          id;
  final String        invoiceId;   // e.g. INV-2026-001
  final String        customer;
  final double        subtotal;
  final double        discount;    // percentage
  final double        tax;
  final double        total;
  final PaymentMethod paymentMethod;
  final SaleStatus    status;
  final DateTime      createdAt;

  const SaleModel({
    this.id,
    required this.invoiceId,
    this.customer      = 'Walk-in Customer',
    required this.subtotal,
    this.discount      = 0,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    this.status        = SaleStatus.completed,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'invoice_id':      invoiceId,
    'customer':        customer,
    'subtotal':        subtotal,
    'discount':        discount,
    'tax':             tax,
    'total':           total,
    'payment_method':  paymentMethod.name,
    'status':          status.name,
    'created_at':      createdAt.toIso8601String(),
  };

  factory SaleModel.fromMap(Map<String, dynamic> map) => SaleModel(
    id:            map['id'] as int?,
    invoiceId:     map['invoice_id'] as String,
    customer:      map['customer'] as String? ?? 'Walk-in Customer',
    subtotal:      (map['subtotal'] as num).toDouble(),
    discount:      (map['discount'] as num?)?.toDouble() ?? 0,
    tax:           (map['tax'] as num).toDouble(),
    total:         (map['total'] as num).toDouble(),
    paymentMethod: PaymentMethod.values.firstWhere(
            (e) => e.name == map['payment_method'], orElse: () => PaymentMethod.cash),
    status:        SaleStatus.values.firstWhere(
            (e) => e.name == map['status'], orElse: () => SaleStatus.completed),
    createdAt:     DateTime.parse(map['created_at'] as String),
  );
}