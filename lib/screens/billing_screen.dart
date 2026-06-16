import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../widgets/barcode_input.dart';
import '../widgets/cart_list.dart';
import '../widgets/total_section.dart';
import '../widgets/payment_form.dart';
import '../core/app_colors_ext.dart';
import '../repositories/product_repository.dart';
import '../repositories/sales_repository.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';

/// ─────────────────────────────────────────────────────────────
///  BILLING SCREEN  –  lib/screens/billing_screen.dart
/// ─────────────────────────────────────────────────────────────
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});
  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _productRepo = ProductRepository();
  final _salesRepo   = SalesRepository();
  final _barcodeKey  = GlobalKey<BarcodeInputState>();

  final List<CartItem> _cart = [];
  bool   _showPayment  = false;
  double _discountPct  = 0;          // synced from TotalSection

  // ── Live search (used by BarcodeInput suggestions) ────────
  Future<List<ProductModel>> _onSearch(String query) =>
      _productRepo.search(query);

  // ── Add a product to cart, with stock checks ──────────────
  void _addProductToCart(ProductModel product) {
    if (product.stock <= 0) { _showOutOfStock(product.name); return; }
    setState(() {
      final idx = _cart.indexWhere((c) => c.id == product.id.toString());
      if (idx >= 0) {
        if (_cart[idx].qty >= _cart[idx].maxStrr ock) {
          _showMaxStock(product.name, _cart[idx].maxStock);
        } else {
          _cart[idx].qty++;
        }
      } else {
        _cart.add(CartItem(
          id:       product.id.toString(),
          barcode:  product.barcode,
          name:     product.name,
          price:    product.sellingPrice,
          maxStock: product.stock,
        ));
      }
    });
  }

  // ── Submit from barcode/search field (Enter / Add Item) ───
  Future<void> _onBarcode(String code) async {
    ProductModel? product = await _productRepo.findByBarcode(code);

    if (product == null) {
      final results = await _productRepo.search(code);
      if (results.length == 1) {
        product = results.first;
      } else if (results.length > 1) {
        product = await _showProductPicker(results);
      }
    }

    if (product == null) { _showNotFound(code); return; }
    _addProductToCart(product);
  }

  Future<ProductModel?> _showProductPicker(List<ProductModel> products) async {
    return showDialog<ProductModel>(
      context: context,
      builder: (ctx) {
        final c = context.colors;
        return AlertDialog(
          backgroundColor: c.cardBg,
          title: Text('Select Product',
              style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 420,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: products.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: c.borderLight),
              itemBuilder: (_, i) {
                final p = products[i];
                return ListTile(
                  title: Text(p.name,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                  subtitle: Text('${p.barcode} • Stock: ${p.stock}',
                      style: TextStyle(fontSize: 12, color: c.textMuted)),
                  trailing: Text('₹${p.sellingPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.teal600)),
                  onTap: () => Navigator.pop(ctx, p),
                );
              },
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
        );
      },
    );
  }

  // ── Cart quantity controls ─────────────────────────────────
  void _onIncrease(CartItem item) {
    if (item.qty >= item.maxStock) {
      _showMaxStock(item.name, item.maxStock);
      return;
    }
    setState(() => item.qty++);
  }

  void _onDecrease(CartItem item) =>
      setState(() { if (item.qty > 1) item.qty--; });

  void _onAddTen(CartItem item) {
    final newQty = item.qty + 10;
    setState(() {
      if (newQty > item.maxStock) {
        item.qty = item.maxStock;
        _showMaxStock(item.name, item.maxStock);
      } else {
        item.qty = newQty;
      }
    });
  }

  void _onResetQty(CartItem item) => setState(() => item.qty = 1);

  void _onRemove(CartItem item) =>
      setState(() => _cart.removeWhere((c) => c.id == item.id));

  double get _subtotal       => _cart.fold(0.0, (s, i) => s + i.total);
  double get _discountAmount => _subtotal * (_discountPct / 100);
  double get _taxAmount      => (_subtotal - _discountAmount) * 0.05;
  double get _finalTotal     => _subtotal - _discountAmount + _taxAmount;

  // ── Confirm payment → save to SQLite ──────────────────────
  Future<void> _onConfirmPayment(PaymentMethod method) async {
    try {
      await _salesRepo.completeSale(
        cartItems:     _cart,
        paymentMethod: method,
        discountPct:   _discountPct,
      );
      setState(() {
        _cart.clear();
        _showPayment = false;
        _discountPct = 0;
      });
      WidgetsBinding.instance.addPostFrameCallback(
              (_) => _barcodeKey.currentState?.requestFocus());
      _showSuccess();
    } catch (e) {
      _showError('Failed to save sale: $e');
    }
  }

  // ── Snackbars ──────────────────────────────────────────────
  void _showNotFound(String code)        => _snack('Product not found: $code', AppColors.red500);
  void _showOutOfStock(String name)      => _snack('Out of stock: $name', AppColors.orange700);
  void _showMaxStock(String name, int max) =>
      _snack('Only $max in stock for "$name" — limit reached', AppColors.orange700);

  void _showSuccess() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: const Row(children: [
      Icon(Icons.check_circle_outline, color: AppColors.white, size: 18),
      SizedBox(width: 8),
      Text('Transaction saved successfully!'),
    ]),
    backgroundColor: AppColors.teal600,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: const Duration(seconds: 2),
  ));

  void _showError(String msg) => _snack(msg, AppColors.red500);

  void _snack(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ));

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.f2) {
      _barcodeKey.currentState?.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _handleKey,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Row(children: [
            Expanded(
              child: Column(children: [
                BarcodeInput(
                  key: _barcodeKey,
                  onSubmit: _onBarcode,
                  onSearch: _onSearch,
                  onSelectSuggestion: _addProductToCart,
                ),
                const SizedBox(height: 14),
                Expanded(child: CartList(
                  items:      _cart,
                  onIncrease: _onIncrease,
                  onDecrease: _onDecrease,
                  onRemove:   _onRemove,
                  onAddTen:   _onAddTen,
                  onResetQty: _onResetQty,
                )),
              ]),
            ),
            const SizedBox(width: 16),
            TotalSection(
              subtotal:  _subtotal,
              itemCount: _cart.length,
              cartEmpty: _cart.isEmpty,
              onProceed: () => setState(() => _showPayment = true),
              onDiscountChanged: (v) => setState(() => _discountPct = v),
            ),
          ]),

          // Payment slide-in
          Positioned(
            top: 0, bottom: 0, right: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              offset: _showPayment ? Offset.zero : const Offset(1, 0),
              child: PaymentForm(
                totalAmount: _finalTotal,            // ← correct final total
                isVisible:   _showPayment,
                onClose:     () => setState(() => _showPayment = false),
                onConfirm:   (method, received) => _showConfirmDialog(method),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        total:     _finalTotal,
        method:    method,
        onConfirm: () { Navigator.of(ctx).pop(); _onConfirmPayment(method); },
        onCancel:  () => Navigator.of(ctx).pop(),
      ),
    );
  }
}

// ── Confirm dialog — payment method is FIXED (read-only) ──────
class _ConfirmDialog extends StatelessWidget {
  final double total;
  final PaymentMethod method;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const _ConfirmDialog({
    required this.total,
    required this.method,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final labels = {PaymentMethod.cash:'Cash', PaymentMethod.upi:'UPI', PaymentMethod.card:'Card'};
    final icons  = {PaymentMethod.cash:Icons.payments_outlined,
      PaymentMethod.upi:Icons.smartphone_outlined, PaymentMethod.card:Icons.credit_card_outlined};

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: c.cardBg,
      child: SizedBox(
        width: 400,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 20),
            child: Column(children: [
              Container(
                width: 60, height: 60,
                decoration: const BoxDecoration(color: AppColors.teal100, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline, color: AppColors.teal600, size: 30),
              ),
              const SizedBox(height: 16),
              Text('Complete Transaction?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary)),
              const SizedBox(height: 4),
              Text('₹${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.teal600)),
              const SizedBox(height: 14),
              // Fixed payment method — NOT selectable here
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.teal50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.teal100),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icons[method]!, size: 18, color: AppColors.teal600),
                  const SizedBox(width: 8),
                  Text('Payment via ${labels[method]!}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal700)),
                ]),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: c.tableHeader,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              border: Border(top: BorderSide(color: c.border)),
            ),
            child: Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.textSecond,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: c.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal600,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Confirm & Save', style: TextStyle(fontWeight: FontWeight.w700)),
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}