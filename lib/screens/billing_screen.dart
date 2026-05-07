import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../widgets/barcode_input.dart';
import '../widgets/cart_list.dart';
import '../widgets/total_section.dart';
import '../widgets/payment_form.dart';

/// ─────────────────────────────────────────────────────────────
///  BILLING SCREEN  –  Main POS billing interface
///  Layout: [BarcodeInput] + [CartList (flex)] + [TotalSection]
///  Overlay: [PaymentForm] slides in from right
///  File: lib/screens/billing_screen.dart
/// ─────────────────────────────────────────────────────────────

// Dummy product catalog (replace with ProductRepository later)
const _catalog = [
  {'id': '1', 'barcode': '890123', 'name': 'Banarasi Silk Saree - Red',   'price': 4500.0, 'stock': 12},
  {'id': '2', 'barcode': '890124', 'name': 'Kanjeevaram Silk - Blue',      'price': 6200.0, 'stock': 5 },
  {'id': '3', 'barcode': '890125', 'name': 'Cotton Printed Saree',         'price': 850.0,  'stock': 40},
  {'id': '4', 'barcode': '890126', 'name': 'Georgette Designer Saree',     'price': 2100.0, 'stock': 15},
  {'id': '5', 'barcode': '890127', 'name': 'Mysore Silk Saree',            'price': 3200.0, 'stock': 18},
];

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final List<CartItem> _cart = [];
  final _barcodeKey = GlobalKey<BarcodeInputState>();
  bool _showPayment = false;

  // ── Cart helpers ────────────────────────────────────────────
  void _onBarcode(String code) {
    final product = _catalog.firstWhere(
          (p) => p['barcode'] == code,
      orElse: () => {},
    );
    if (product.isEmpty) {
      _showNotFound(code);
      return;
    }
    setState(() {
      final existing = _cart.indexWhere((c) => c.id == product['id']);
      if (existing >= 0) {
        _cart[existing].qty++;
      } else {
        _cart.add(CartItem(
          id:      product['id'] as String,
          barcode: product['barcode'] as String,
          name:    product['name'] as String,
          price:   product['price'] as double,
        ));
      }
    });
  }

  void _onIncrease(CartItem item) =>
      setState(() => item.qty++);

  void _onDecrease(CartItem item) =>
      setState(() { if (item.qty > 1) item.qty--; });

  void _onRemove(CartItem item) =>
      setState(() => _cart.removeWhere((c) => c.id == item.id));

  void _onConfirmPayment() {
    setState(() {
      _cart.clear();
      _showPayment = false;
    });
    // Refocus barcode after transaction
    WidgetsBinding.instance.addPostFrameCallback(
            (_) => _barcodeKey.currentState?.requestFocus());
    _showSuccessSnackbar();
  }

  double get _subtotal => _cart.fold(0, (s, i) => s + i.total);

  // ── UI helpers ──────────────────────────────────────────────
  void _showNotFound(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Product not found: $code'),
        backgroundColor: AppColors.red500,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_outline, color: AppColors.white, size: 18),
          SizedBox(width: 8),
          Text('Transaction completed successfully!'),
        ]),
        backgroundColor: AppColors.teal600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ── Keyboard shortcuts ──────────────────────────────────────
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.f2) {
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
        children: [
          // ── Main content ───────────────────────────────────
          Row(
            children: [
              // Left: scan bar + cart
              Expanded(
                child: Column(
                  children: [
                    BarcodeInput(
                      key: _barcodeKey,
                      onSubmit: _onBarcode,
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: CartList(
                        items: _cart,
                        onIncrease: _onIncrease,
                        onDecrease: _onDecrease,
                        onRemove:   _onRemove,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Right: totals
              TotalSection(
                subtotal:  _subtotal,
                cartEmpty: _cart.isEmpty,
                onProceed: () => setState(() => _showPayment = true),
              ),
            ],
          ),

          // ── Payment slide-in overlay ───────────────────────
          if (_showPayment || true) // Always in tree for animation
            Positioned(
              top: 0, bottom: 0, right: 0,
              child: PaymentForm(
                totalAmount: _subtotal * 1.05,  // rough total with 5% GST
                isVisible:   _showPayment,
                onClose:     () => setState(() => _showPayment = false),
                onConfirm:   _onPaymentConfirmDialog,
              ),
            ),
        ],
      ),
    );
  }

  void _onPaymentConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        total: _subtotal * 1.05,
        onConfirm: () {
          Navigator.of(ctx).pop();
          _onConfirmPayment();
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }
}

// ── Confirmation dialog ───────────────────────────────────────────────────────
class _ConfirmDialog extends StatelessWidget {
  final double total;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmDialog(
      {required this.total, required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 20),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.teal100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.help_outline,
                        color: AppColors.teal600, size: 30),
                  ),
                  const SizedBox(height: 16),
                  const Text('Complete Transaction?',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900)),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to finalise this bill for\n₹${total.toStringAsFixed(2)}?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(color: AppColors.gray500),
                  ),
                ],
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                border: Border(top: BorderSide(color: AppColors.gray200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gray700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        side: const BorderSide(color: AppColors.gray300),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal600,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Yes, Print Bill',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
