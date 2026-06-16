import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';
import '../models/product_model.dart';

class BarcodeInput extends StatefulWidget {
  final ValueChanged<String> onSubmit;                       // Enter / Add Item (barcode or name → exact/auto match)
  final Future<List<ProductModel>> Function(String query) onSearch; // live search
  final ValueChanged<ProductModel> onSelectSuggestion;        // tap a suggestion
  const BarcodeInput({
    super.key,
    required this.onSubmit,
    required this.onSearch,
    required this.onSelectSuggestion,
  });
  @override
  State<BarcodeInput> createState() => BarcodeInputState();
}

class BarcodeInputState extends State<BarcodeInput> {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();

  List<ProductModel> _suggestions = [];

  void requestFocus() => _focus.requestFocus();

  void _submit() {
    final val = _ctrl.text.trim();
    if (val.isEmpty) return;
    widget.onSubmit(val);
    _clear();
  }

  void _clear() {
    _ctrl.clear();
    setState(() => _suggestions = []);
    _focus.requestFocus();
  }

  Future<void> _onChanged(String v) async {
    final q = v.trim();
    if (q.length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    final results = await widget.onSearch(q);
    if (mounted) setState(() => _suggestions = results.take(5).toList());
  }

  void _onSelect(ProductModel p) {
    widget.onSelectSuggestion(p);
    _clear();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: _suggestions.isEmpty
              ? BorderRadius.circular(10)
              : const BorderRadius.vertical(top: Radius.circular(10)),
          border: Border.all(color: c.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
        ),
        child: Row(children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                onChanged: _onChanged,
                onSubmitted: (_) => _submit(),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Scan barcode or type product name…',
                  prefixIcon: Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.qr_code_scanner_outlined, size: 22, color: c.textMuted)),
                  prefixIconConstraints: const BoxConstraints(minWidth: 48),
                  filled: true,
                  fillColor: c.inputFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: c.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: c.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.teal600, width: 2)),
                  hintStyle: TextStyle(fontSize: 14, color: c.textMuted),
                ),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal600,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                elevation: 0,
              ),
            ),
          ),
        ]),
      ),

      // ── Live suggestions dropdown ─────────────────────────
      if (_suggestions.isNotEmpty)
        Container(
          decoration: BoxDecoration(
            color: c.cardBg,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
            border: Border(
              left: BorderSide(color: c.border),
              right: BorderSide(color: c.border),
              bottom: BorderSide(color: c.border),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
          ),
          child: Column(
            children: _suggestions.map((p) {
              final outOfStock = p.stock <= 0;
              return InkWell(
                onTap: outOfStock ? null : () => _onSelect(p),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    Icon(Icons.inventory_2_outlined, size: 16, color: c.textMuted),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                            color: outOfStock ? c.textMuted : c.textPrimary)),
                        Text('${p.barcode} • Stock: ${p.stock}',
                            style: TextStyle(fontSize: 11, color: c.textMuted)),
                      ],
                    )),
                    Text('₹${p.sellingPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: outOfStock ? c.textMuted : AppColors.teal600)),
                    if (outOfStock) Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text('Out of stock', style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.red500)),
                    ),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
    ]);
  }
}