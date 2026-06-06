import '../database/dao/sales_dao.dart';
import '../database/dao/product_dao.dart';
import '../models/sale_model.dart';
import '../models/sale_item_model.dart';
import '../widgets/cart_list.dart';

/// ─────────────────────────────────────────────────────────────
///  SALES REPOSITORY  –  lib/repositories/sales_repository.dart
/// ─────────────────────────────────────────────────────────────
class SalesRepository {
  final _salesDao   = SalesDao();
  final _productDao = ProductDao();

  // ── Complete a sale ────────────────────────────────────────
  Future<SaleModel> completeSale({
    required List<CartItem> cartItems,
    required PaymentMethod  paymentMethod,
    double discountPct = 0,
    double taxRate     = 0.05,
    String customer    = 'Walk-in Customer',
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

    final saleItems = cartItems.map((item) => SaleItemModel(
      saleId:      0,
      productId:   int.parse(item.id),
      productName: item.name,
      barcode:     item.barcode,
      unitPrice:   item.price,
      qty:         item.qty,
      total:       item.total,
    )).toList();

    // Save sale + items in one transaction
    final saleId = await _salesDao.insertSaleWithItems(sale, saleItems);

    // Decrease stock for each product
    for (final item in cartItems) {
      await _productDao.adjustStock(int.parse(item.id), -item.qty);
    }

    // Return saved sale with generated id
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

  // ── Get all sales ──────────────────────────────────────────
  Future<List<SaleModel>> getAllSales({int limit = 50}) =>
      _salesDao.getAll(limit: limit);

  // ── Get today's sales ──────────────────────────────────────
  Future<List<SaleModel>> getTodaySales() => _salesDao.getToday();

  // ── Get by date range ──────────────────────────────────────
  Future<List<SaleModel>> getByDateRange(DateTime from, DateTime to) =>
      _salesDao.getByDateRange(from, to);

  // ── Get items for a sale ───────────────────────────────────
  Future<List<SaleItemModel>> getSaleItems(int saleId) =>
      _salesDao.getItemsForSale(saleId);

  // ── Refund ─────────────────────────────────────────────────
  Future<void> refundSale(int saleId) =>
      _salesDao.updateStatus(saleId, SaleStatus.refunded);

  // ── Today's revenue ────────────────────────────────────────
  Future<double> todayRevenue() => _salesDao.todayRevenue();
}