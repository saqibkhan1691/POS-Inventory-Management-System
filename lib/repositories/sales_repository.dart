import '../database/dao/sales_dao.dart';
import '../database/dao/product_dao.dart';
import '../models/sale_model.dart';
import '../models/sale_item_model.dart';
import '../widgets/cart_list.dart';  // CartItem

/// ─────────────────────────────────────────────────────────────
///  SALES REPOSITORY  –  lib/repositories/sales_repository.dart
///  Handles completing a sale: save bill + items + update stock
/// ─────────────────────────────────────────────────────────────
class SalesRepository {
  final _salesDao   = SalesDao();
  final _productDao = ProductDao();

  // ── COMPLETE A SALE ────────────────────────────────────────
  Future<SaleModel> completeSale({
    required List<CartItem>   cartItems,
    required PaymentMethod    paymentMethod,
    double                    discountPct = 0,
    double                    taxRate     = 0.05,
    String                    customer    = 'Walk-in Customer',
  }) async {
    final subtotal       = cartItems.fold(0.0, (s, i) => s + i.total);
    final discountAmount = subtotal * (discountPct / 100);
    final taxableAmount  = subtotal - discountAmount;
    final tax            = taxableAmount * taxRate;
    final total          = taxableAmount + tax;
    final invoiceId      = await _salesDao.generateInvoiceId();
    final now            = DateTime.now();

    final sale = SaleModel(
      invoiceId:     invoiceId,
      customer:      customer,
      subtotal:      subtotal,
      discount:      discountPct,
      tax:           tax,
      total:         total,
      paymentMethod: paymentMethod,
      status:        SaleStatus.completed,
      createdAt:     now,
    );

    // Build sale items
    final saleItems = cartItems.map((item) => SaleItemModel(
      saleId:      0,  // set after insert
      productId:   int.parse(item.id),
      productName: item.name,
      barcode:     item.barcode,
      unitPrice:   item.price,
      qty:         item.qty,
      total:       item.total,
    )).toList();

    // Save to DB in one transaction
    final saleId = await _salesDao.insertSaleWithItems(sale, saleItems);

    // Decrease stock for each product
    for (final item in cartItems) {
      await _productDao.adjustStock(int.parse(item.id), -item.qty);
    }

    return SaleModel(
      id:            saleId,
      invoiceId:     invoiceId,
      customer:      customer,
      subtotal:      subtotal,
      discount:      discountPct,
      tax:           tax,
      total:         total,
      paymentMethod: paymentMethod,
      status:        SaleStatus.completed,
      createdAt:     now,
    );
  }

  // ── GET ALL TRANSACTIONS ───────────────────────────────────
  Future<List<SaleModel>> getAllSales({int limit = 50}) =>
      _salesDao.getAll(limit: limit);

  // ── GET TODAY ──────────────────────────────────────────────
  Future<List<SaleModel>> getTodaySales() => _salesDao.getToday();

  // ── GET BY DATE RANGE ──────────────────────────────────────
  Future<List<SaleModel>> getByDateRange(DateTime from, DateTime to) =>
      _salesDao.getByDateRange(from, to);

  // ── GET ITEMS FOR SALE ─────────────────────────────────────
  Future<List<SaleItemModel>> getSaleItems(int saleId) =>
      _salesDao.getItemsForSale(saleId);

  // ── REFUND ─────────────────────────────────────────────────
  Future<void> refundSale(int saleId) =>
      _salesDao.updateStatus(saleId, SaleStatus.refunded);

  // ── TODAY'S REVENUE ────────────────────────────────────────
  Future<double> todayRevenue() => _salesDao.todayRevenue();
}