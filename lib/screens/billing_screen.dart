import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../widgets/barcode_input.dart';
import '../widgets/cart_list.dart';
import '../widgets/total_section.dart';
import '../widgets/payment_form.dart' hide PaymentMethod;
import '../models/sale_model.dart';

import '../core/app_colors_ext.dart';
import '../repositories/product_repository.dart';
import '../repositories/sales_repository.dart';
import '../models/product_model.dart';

/// ─────────────────────────────────────────────────────────────
///  BILLING SCREEN  –  lib/screens/billing_screen.dart
///  Now connected to SQLite via ProductRepository + SalesRepository
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
  bool   _showPayment   = false;
  double _discountPct   = 0;

  // ── Barcode scan → lookup in DB ────────────────────────────
  Future<void> _onBarcode(String code) async {
    final product = await _productRepo.findByBarcode(code);
    if (product == null) {
      _showNotFound(code);
      return;
    }
    if (product.stock <= 0) {
      _showOutOfStock(product.name);
      return;
    }
    setState(() {
      final existing = _cart.indexWhere((c) => c.id == product.id.toString());
      if (existing >= 0) {
        _cart[existing].qty++;
      } else {
        _cart.add(CartItem(
          id:      product.id.toString(),
          barcode: product.barcode,
          name:    product.name,
          price:   product.sellingPrice,
        ));
      }
    });
  }

  void _onIncrease(CartItem item) => setState(() => item.qty++);
  void _onDecrease(CartItem item) => setState(() { if (item.qty > 1) item.qty--; });
  void _onRemove(CartItem item)   => setState(() => _cart.removeWhere((c) => c.id == item.id));

  double get _subtotal => _cart.fold(0.0, (s, i) => s + i.total);

  // ── Confirm payment → save to SQLite ──────────────────────
  Future<void> _onConfirmPayment(PaymentMethod method) async {
    try {
      await _salesRepo.completeSale(
        cartItems:     _cart,
        paymentMethod: method,
        discountPct:   _discountPct,
      );
      setState(() { _cart.clear(); _showPayment = false; _discountPct = 0; });
      WidgetsBinding.instance.addPostFrameCallback(
              (_) => _barcodeKey.currentState?.requestFocus());
      _showSuccess();
    } catch (e) {
      _showError('Failed to save sale: $e');
    }
  }

  // ── UI helpers ─────────────────────────────────────────────
  void _showNotFound(String code) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Product not found: $code'),
    backgroundColor: AppColors.red500,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: const Duration(seconds: 2),
  ));

  void _showOutOfStock(String name) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Out of stock: $name'),
    backgroundColor: AppColors.orange700,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: const Duration(seconds: 2),
  ));

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

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: AppColors.red500,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                BarcodeInput(key: _barcodeKey, onSubmit: _onBarcode),
                const SizedBox(height: 14),
                Expanded(child: CartList(
                  items:      _cart,
                  onIncrease: _onIncrease,
                  onDecrease: _onDecrease,
                  onRemove:   _onRemove,
                )),
              ]),
            ),
            const SizedBox(width: 16),
            TotalSection(
              subtotal:  _subtotal,
              cartEmpty: _cart.isEmpty,
              onProceed: () => setState(() => _showPayment = true),
            ),
          ]),

          // Payment slide-in overlay
          Positioned(
            top: 0, bottom: 0, right: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              offset: _showPayment ? Offset.zero : const Offset(1, 0),
              child: PaymentForm(
                totalAmount: _subtotal * 1.05,
                isVisible:   _showPayment,
                onClose:     () => setState(() => _showPayment = false),
                onConfirm:   () => _showConfirmDialog(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        total:     _subtotal * 1.05,
        onConfirm: (method) { Navigator.of(ctx).pop(); _onConfirmPayment(method); },
        onCancel:  () => Navigator.of(ctx).pop(),
      ),
    );
  }
}

// ── Confirmation dialog with payment method ───────────────────
class _ConfirmDialog extends StatefulWidget {
  final double total;
  final void Function(PaymentMethod) onConfirm;
  final VoidCallback onCancel;
  const _ConfirmDialog({required this.total, required this.onConfirm, required this.onCancel});
  @override State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  PaymentMethod _method = PaymentMethod.cash;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: c.cardBg,
      child: SizedBox(
        width: 420,
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
              Text('Total: ₹${widget.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.teal600)),
              const SizedBox(height: 16),
              // Payment method selector
              Row(children: PaymentMethod.values.map((m) {
                final labels = {PaymentMethod.cash:'Cash', PaymentMethod.upi:'UPI', PaymentMethod.card:'Card'};
                final icons  = {PaymentMethod.cash:Icons.payments_outlined, PaymentMethod.upi:Icons.smartphone_outlined, PaymentMethod.card:Icons.credit_card_outlined};
                final sel = _method == m;
                return Expanded(child: Padding(
                  padding: EdgeInsets.only(right: m != PaymentMethod.card ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _method = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.teal50 : c.cardBg,
                        border: Border.all(color: sel ? AppColors.teal600 : c.border, width: sel ? 2 : 1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Column(children: [
                        Icon(icons[m]!, size: 20, color: sel ? AppColors.teal600 : c.textMuted),
                        const SizedBox(height: 4),
                        Text(labels[m]!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                            color: sel ? AppColors.teal700 : c.textSecond)),
                      ]),
                    ),
                  ),
                ));
              }).toList()),
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
                onPressed: widget.onCancel,
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
                onPressed: () => widget.onConfirm(_method),
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