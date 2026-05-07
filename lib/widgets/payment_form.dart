import 'package:flutter/material.dart';
import '../core/theme.dart';

/// ─────────────────────────────────────────────────────────────
///  PAYMENT FORM  –  Slide-in right panel for payment processing
///  Payment method selector + amount received + change display
/// ─────────────────────────────────────────────────────────────

enum PaymentMethod { cash, upi, card }

class PaymentForm extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onClose;
  final VoidCallback onConfirm;
  final bool isVisible;

  const PaymentForm({
    super.key,
    required this.totalAmount,
    required this.onClose,
    required this.onConfirm,
    required this.isVisible,
  });

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;

  PaymentMethod _method = PaymentMethod.cash;
  final _amountCtrl = TextEditingController();

  double get _received   => double.tryParse(_amountCtrl.text) ?? 0;
  double get _change     => (_received - widget.totalAmount).clamp(0, double.infinity);
  bool   get _hasEnough  => _received >= widget.totalAmount;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _slideAnim = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    if (widget.isVisible) _animCtrl.forward();
  }

  @override
  void didUpdateWidget(PaymentForm old) {
    super.didUpdateWidget(old);
    if (widget.isVisible != old.isVisible) {
      widget.isVisible ? _animCtrl.forward() : _animCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(left: BorderSide(color: AppColors.gray200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(-4, 0),
            )
          ],
        ),
        child: Column(
          children: [
            // ── Header ────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              color: AppColors.slate900,
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Payment',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: AppColors.slate300, size: 22),
                  ),
                ],
              ),
            ),

            // ── Body ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.teal50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.teal100),
                      ),
                      child: Column(
                        children: [
                          const Text('Amount to Pay',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.teal700)),
                          const SizedBox(height: 6),
                          Text(
                            '₹${widget.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: AppColors.teal600),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Method picker
                    const Text('SELECT METHOD',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray400,
                            letterSpacing: 1.0)),
                    const SizedBox(height: 10),
                    Row(
                      children: PaymentMethod.values
                          .map((m) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: m != PaymentMethod.card ? 8 : 0),
                          child: _MethodTile(
                            method: m,
                            selected: _method == m,
                            onTap: () => setState(() => _method = m),
                          ),
                        ),
                      ))
                          .toList(),
                    ),

                    const SizedBox(height: 24),

                    // Amount received
                    const Text('AMOUNT RECEIVED',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray400,
                            letterSpacing: 1.0)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Enter amount…',
                        filled: true,
                        fillColor: AppColors.gray50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.gray300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.gray300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                          const BorderSide(color: AppColors.teal600, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800),
                    ),

                    // Change display
                    if (_amountCtrl.text.isNotEmpty && _hasEnough) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.green100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text('Change:',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.green700)),
                            ),
                            Text(
                              '₹${_change.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.green700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Confirm button ────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.gray50,
                border: Border(top: BorderSide(color: AppColors.gray200)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal600,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                    elevation: 0,
                  ),
                  child: const Text('Confirm & Print Bill'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Method tile ───────────────────────────────────────────────────────────────
class _MethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile(
      {required this.method, required this.selected, required this.onTap});

  static const _labels = {
    PaymentMethod.cash: 'Cash',
    PaymentMethod.upi:  'UPI',
    PaymentMethod.card: 'Card',
  };
  static const _icons = {
    PaymentMethod.cash: Icons.payments_outlined,
    PaymentMethod.upi:  Icons.smartphone_outlined,
    PaymentMethod.card: Icons.credit_card_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal50 : AppColors.white,
          border: Border.all(
            color: selected ? AppColors.teal600 : AppColors.gray200,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          children: [
            Icon(_icons[method]!,
                size: 22,
                color: selected ? AppColors.teal600 : AppColors.gray500),
            const SizedBox(height: 6),
            Text(
              _labels[method]!,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.teal700 : AppColors.gray600),
            ),
          ],
        ),
      ),
    );
  }
}
