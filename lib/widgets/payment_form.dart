import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';
import '../models/sale_model.dart'; // PaymentMethod enum

class PaymentForm extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onClose;
  final void Function(PaymentMethod method, double received) onConfirm;
  final bool isVisible;
  const PaymentForm({super.key, required this.totalAmount, required this.onClose,
    required this.onConfirm, required this.isVisible});
  @override State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  PaymentMethod _method = PaymentMethod.cash;
  final _amountCtrl = TextEditingController();
  String? _error;

  double get _received  => double.tryParse(_amountCtrl.text) ?? 0;
  double get _change    => (_received - widget.totalAmount).clamp(0, double.infinity);
  bool   get _hasEnough => _received >= widget.totalAmount;

  @override void dispose() { _amountCtrl.dispose(); super.dispose(); }

  void _onMethodChanged(PaymentMethod m) {
    setState(() {
      _method = m;
      _error  = null;
      if (m != PaymentMethod.cash) _amountCtrl.clear();
    });
  }

  void _onConfirmPressed() {
    if (_method == PaymentMethod.cash) {
      if (_amountCtrl.text.trim().isEmpty) {
        setState(() => _error = 'Enter amount before proceeding');
        return;
      }
      if (double.tryParse(_amountCtrl.text) == null) {
        setState(() => _error = 'Enter a valid number');
        return;
      }
      if (!_hasEnough) {
        setState(() => _error = 'Amount received is less than total');
        return;
      }
      setState(() => _error = null);
      widget.onConfirm(_method, _received);
    } else {
      // UPI / Card — exact amount, no "received" needed
      widget.onConfirm(_method, widget.totalAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
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
            const Expanded(child: Text('Payment', style: TextStyle(
                color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w700))),
            IconButton(onPressed: widget.onClose,
                icon: const Icon(Icons.close, color: AppColors.slate300, size: 22)),
          ]),
        ),
        // Body
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Amount box — this is the FINAL total (after discount + tax)
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
                    onTap: () => _onMethodChanged(m)),
              ),
            )).toList()),
            const SizedBox(height: 24),

            // Amount received — only for CASH
            if (_method == PaymentMethod.cash) ...[
              Text('AMOUNT RECEIVED', style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: c.textMuted, letterSpacing: 1.0)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() => _error = null),
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
              // Change — only shown for cash, when enough received
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
            ] else ...[
              // UPI / Card — exact amount note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: c.inputFill,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.border),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline, size: 18, color: c.textMuted),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                      'Exact amount of ₹${widget.totalAmount.toStringAsFixed(2)} '
                          'will be charged via ${_method == PaymentMethod.upi ? "UPI" : "Card"}.',
                      style: TextStyle(fontSize: 13, color: c.textSecond))),
                ]),
              ),
            ],

            // Error message
            if (_error != null) Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.red50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.red100),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline, size: 16, color: AppColors.red500),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.red700))),
                ]),
              ),
            ),
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
              onPressed: _onConfirmPressed,
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