import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';

class TotalSection extends StatefulWidget {
  final double subtotal;
  final double taxRate;
  final bool cartEmpty;
  final VoidCallback onProceed;
  const TotalSection({super.key, required this.subtotal, required this.onProceed,
    this.taxRate = 0.05, this.cartEmpty = true});
  @override State<TotalSection> createState() => _TotalSectionState();
}

class _TotalSectionState extends State<TotalSection> {
  double _discount = 0;
  final _discCtrl  = TextEditingController(text: '0');

  double get tax => (widget.subtotal - _discountAmount) * widget.taxRate;
  double get finalTotal => widget.subtotal - _discountAmount + tax;
  double get _discountAmount => (widget.subtotal * _discount) / 100;

  @override void dispose() { _discCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: const BoxDecoration(
            color: AppColors.slate900,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Bill Summary', style: TextStyle(color: AppColors.white,
                fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('Items in cart: ${widget.cartEmpty ? 0 : "–"}',
                style: const TextStyle(fontSize: 12, color: AppColors.slate400)),
          ]),
        ),
        // Body
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(children: [
              _Row('Subtotal', '₹${widget.subtotal.toStringAsFixed(2)}', c),
              const SizedBox(height: 14),
              // Discount input
              Row(children: [
                Expanded(child: Text('Discount (₹)',
                    style: TextStyle(fontSize: 14, color: c.textSecond))),
                SizedBox(width: 88, height: 34,
                  child: TextField(
                    controller: _discCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    onChanged: (v) => setState(() => _discount = double.tryParse(v) ?? 0),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      filled: true, fillColor: c.inputFill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: c.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: c.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.teal600, width: 1.5)),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              _Row('Tax (GST ${(widget.taxRate*100).toStringAsFixed(0)}%)',
                  '₹${tax.toStringAsFixed(2)}', c),
              Padding(padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, thickness: 1, color: c.divider)),
              Align(alignment: Alignment.centerLeft,
                  child: Text('FINAL TOTAL', style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w700, color: c.textMuted, letterSpacing: 1.0))),
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerLeft,
                  child: Text('₹${finalTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900,
                          color: AppColors.teal600, height: 1.1))),
            ]),
          ),
        ),
        // Footer
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.tableHeader,
            border: Border(top: BorderSide(color: c.border)),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
          child: SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: widget.cartEmpty ? null : widget.onProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal600,
                disabledBackgroundColor: c.border,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                elevation: 0,
              ),
              child: const Text('Proceed to Payment'),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final AdaptiveColors c;
  const _Row(this.label, this.value, this.c);
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: c.textSecond))),
    Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
  ]);
}