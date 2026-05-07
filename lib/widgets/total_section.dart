import 'package:flutter/material.dart';
import '../core/theme.dart';

/// ─────────────────────────────────────────────────────────────
///  TOTAL SECTION  –  Right panel bill summary card
///  Shows subtotal, discount, tax, final total, Proceed button
/// ─────────────────────────────────────────────────────────────
class TotalSection extends StatefulWidget {
  final double subtotal;
  final double taxRate;        // e.g. 0.05 for 5 %
  final bool   cartEmpty;
  final VoidCallback onProceed;

  const TotalSection({
    super.key,
    required this.subtotal,
    required this.onProceed,
    this.taxRate  = 0.05,
    this.cartEmpty = true,
  });

  @override
  State<TotalSection> createState() => _TotalSectionState();
}

class _TotalSectionState extends State<TotalSection> {
  double _discount = 0;
  final _discCtrl  = TextEditingController(text: '0');

  double get tax       => widget.subtotal * widget.taxRate;
  double get finalTotal => widget.subtotal - _discount + tax;

  @override
  void dispose() {
    _discCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: const BoxDecoration(
              color: AppColors.slate900,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bill Summary',
                    style: TextStyle(
                        color: AppColors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'Items in cart: ${widget.cartEmpty ? 0 : "–"}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.slate400),
                ),
              ],
            ),
          ),

          // ── Totals area ──────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                children: [
                  _SummaryRow(label: 'Subtotal',
                      value: '₹${widget.subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 14),

                  // Discount row with inline input
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Discount (₹)',
                            style: AppTextStyles.body),
                      ),
                      SizedBox(
                        width: 88,
                        height: 34,
                        child: TextField(
                          controller: _discCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          onChanged: (v) =>
                              setState(() => _discount = double.tryParse(v) ?? 0),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            filled: true,
                            fillColor: AppColors.gray50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: AppColors.gray300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: AppColors.gray300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: AppColors.teal600, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _SummaryRow(
                    label: 'Tax (GST ${(widget.taxRate * 100).toStringAsFixed(0)}%)',
                    value: '₹${tax.toStringAsFixed(2)}',
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.gray200,
                      // dashed appearance via decoration on Container below instead
                    ),
                  ),

                  // Final total
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('FINAL TOTAL',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray400,
                            letterSpacing: 1.0)),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '₹${finalTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: AppColors.teal600,
                          height: 1.1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Proceed button ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.gray50,
              border: Border(top: BorderSide(color: AppColors.gray200)),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.cartEmpty ? null : widget.onProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal600,
                  disabledBackgroundColor: AppColors.gray300,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  elevation: 0,
                ),
                child: const Text('Proceed to Payment'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.body)),
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
      ],
    );
  }
}
