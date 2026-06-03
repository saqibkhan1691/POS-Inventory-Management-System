import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';
import '../models/sale_model.dart';

class PaymentForm extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onClose, onConfirm;
  final bool isVisible;
  const PaymentForm({super.key, required this.totalAmount, required this.onClose,
    required this.onConfirm, required this.isVisible});
  @override State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<Offset> _slide;
  PaymentMethod _method = PaymentMethod.cash;
  final _amountCtrl = TextEditingController();

  double get _received  => double.tryParse(_amountCtrl.text) ?? 0;
  double get _change    => (_received - widget.totalAmount).clamp(0, double.infinity);
  bool   get _hasEnough => _received >= widget.totalAmount;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _slide = Tween<Offset>(begin: const Offset(1,0), end: Offset.zero)
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

  @override void dispose() { _animCtrl.dispose(); _amountCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SlideTransition(
      position: _slide,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: c.cardBg,
          border: Border(left: BorderSide(color: c.border)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
              blurRadius: 20, offset: const Offset(-4, 0))],
        ),
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            color: AppColors.slate900,
            child: Row(children: [
              Expanded(child: const Text('Payment', style: TextStyle(
                  color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w700))),
              IconButton(onPressed: widget.onClose,
                  icon: const Icon(Icons.close, color: AppColors.slate300, size: 22)),
            ]),
          ),
          // Body
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Amount box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.teal50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.teal100),
                ),
                child: Column(children: [
                  const Text('Amount to Pay', style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w600, color: AppColors.teal700)),
                  const SizedBox(height: 6),
                  Text('₹${widget.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900,
                          color: AppColors.teal600)),
                ]),
              ),
              const SizedBox(height: 24),
              // Method
              Text('SELECT METHOD', style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: c.textMuted, letterSpacing: 1.0)),
              const SizedBox(height: 10),
              Row(children: PaymentMethod.values.map((m) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: m != PaymentMethod.card ? 8 : 0),
                  child: _MethodTile(method: m, selected: _method == m,
                      onTap: () => setState(() => _method = m)),
                ),
              )).toList()),
              const SizedBox(height: 24),
              // Amount received
              Text('AMOUNT RECEIVED', style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: c.textMuted, letterSpacing: 1.0)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Enter amount…',
                  filled: true, fillColor: c.inputFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: c.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: c.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.teal600, width: 2)),
                  hintStyle: TextStyle(color: c.textMuted),
                ),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.textPrimary),
              ),
              // Change
              if (_amountCtrl.text.isNotEmpty && _hasEnough) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(children: [
                    const Expanded(child: Text('Change:', style: TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w600, color: AppColors.green700))),
                    Text('₹${_change.toStringAsFixed(2)}', style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.green700)),
                  ]),
                ),
              ],
            ]),
          )),
          // Confirm
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: c.tableHeader,
              border: Border(top: BorderSide(color: c.border)),
            ),
            child: SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: widget.onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal600, foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  elevation: 0,
                ),
                child: const Text('Confirm & Print Bill'),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;
  const _MethodTile({required this.method, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final labels = {PaymentMethod.cash:'Cash', PaymentMethod.upi:'UPI', PaymentMethod.card:'Card'};
    final icons  = {PaymentMethod.cash:Icons.payments_outlined,
      PaymentMethod.upi:Icons.smartphone_outlined, PaymentMethod.card:Icons.credit_card_outlined};
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal50 : c.cardBg,
          border: Border.all(color: selected ? AppColors.teal600 : c.border,
              width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(children: [
          Icon(icons[method]!, size: 22, color: selected ? AppColors.teal600 : c.textMuted),
          const SizedBox(height: 6),
          Text(labels[method]!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: selected ? AppColors.teal700 : c.textSecond)),
        ]),
      ),
    );
  }
}