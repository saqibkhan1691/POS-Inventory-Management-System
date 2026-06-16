import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';

class TotalSection extends StatefulWidget {
  final double subtotal;
  final int    itemCount;          // ← real cart item count
  final double taxRate;
  final bool   cartEmpty;
  final VoidCallback onProceed;
  final ValueChanged<double> onDiscountChanged; // notifies parent of % value

  const TotalSection({
    super.key,
    required this.subtotal,
    required this.itemCount,
    required this.onProceed,
    required this.onDiscountChanged,
    this.taxRate = 0.05,
    this.cartEmpty = true,
  });
  @override State<TotalSection> createState() => _TotalSectionState();
}

class _TotalSectionState extends State<TotalSection> {
  double _discount = 0; // percent (0-100)
  final _discCtrl   = TextEditingController(text: '0');
  String? _discError;

  double get discountAmount => widget.subtotal * (_discount / 100);
  double get taxableAmount  => widget.subtotal - discountAmount;
  double get tax            => taxableAmount * widget.taxRate;
  double get finalTotal     => taxableAmount + tax;

  @override void dispose() { _discCtrl.dispose(); super.dispose(); }

  void _onDiscountChanged(String v) {
    if (v.trim().isEmpty) {
      setState(() { _discount = 0; _discError = null; });
      widget.onDiscountChanged(0);
      return;
    }
    final val = double.tryParse(v);
    if (val == null) {
      setState(() => _discError = 'Enter a valid number');
      return; // don't update discount on invalid input
    }
    if (val < 0 || val > 100) {
      setState(() => _discError = '0–100 only');
      return;
    }
    setState(() { _discount = val; _discError = null; });
    widget.onDiscountChanged(val);
  }

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
            Text('Items in cart: ${widget.itemCount}',
                style: const TextStyle(fontSize: 12, color: AppColors.slate400)),
          ]),
        ),
        // Body
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Row('Subtotal', '₹${widget.subtotal.toStringAsFixed(2)}', c),
              const SizedBox(height: 14),
              // Discount % input
              Row(children: [
                Expanded(child: Text('Discount (%)',
                    style: TextStyle(fontSize: 14, color: c.textSecond))),
                SizedBox(width: 88, height: 34,
                  child: TextField(
                    controller: _discCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    onChanged: _onDiscountChanged,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary),
                    decoration: InputDecoration(
                      suffixText: '%',
                      suffixStyle: TextStyle(fontSize: 12, color: c.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
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
              if (_discError != null) Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Align(alignment: Alignment.centerRight,
                    child: Text(_discError!, style: const TextStyle(
                        fontSize: 11, color: AppColors.red500, fontWeight: FontWeight.w600))),
              ),
              if (_discount > 0) Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _Row('Discount Amount', '- ₹${discountAmount.toStringAsFixed(2)}', c),
              ),
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