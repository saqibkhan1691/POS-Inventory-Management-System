import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';
import '../repositories/product_repository.dart';

/// ─────────────────────────────────────────────────────────────
///  ADD PRODUCT SCREEN  –  lib/screens/add_product_screen.dart
///  Now saves to SQLite via ProductRepository
/// ─────────────────────────────────────────────────────────────
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _repo    = ProductRepository();
  final _formKey = GlobalKey<FormState>();
  bool _saving   = false;
  bool _autoSku  = true;

  final _nameCtrl     = TextEditingController();
  final _skuCtrl      = TextEditingController();
  final _purchaseCtrl = TextEditingController();
  final _sellingCtrl  = TextEditingController();
  final _alertQtyCtrl = TextEditingController(text: '5');
  final _descCtrl     = TextEditingController();
  final _stockCtrl    = TextEditingController(text: '0');

  String _brand       = 'In-House';
  String _category    = '';
  String _taxType     = '5';
  String _barcodeType = 'CODE128';

  String _customBrand    = '';
  String _customCategory = '';
  List<String> _extraBrands     = [];
  List<String> _extraCategories = [];

  @override
  void dispose() {
    for (final c in [_nameCtrl, _skuCtrl, _purchaseCtrl, _sellingCtrl,
      _alertQtyCtrl, _descCtrl, _stockCtrl]) c.dispose();
    super.dispose();
  }

  // Auto-generate barcode from name + timestamp
  String _generateBarcode() {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    return ts.substring(ts.length - 8);
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final barcode = _autoSku ? _generateBarcode() : _skuCtrl.text.trim();
      await _repo.addProduct(
        name:          _nameCtrl.text.trim(),
        barcode:       barcode,
        category:      _category,
        brand:         _brand,
        purchasePrice: double.tryParse(_purchaseCtrl.text) ?? 0,
        sellingPrice:  double.tryParse(_sellingCtrl.text) ?? 0,
        taxRate:       (double.tryParse(_taxType) ?? 5) / 100,
        stock:         int.tryParse(_stockCtrl.text) ?? 0,
        alertQty:      int.tryParse(_alertQtyCtrl.text) ?? 5,
        barcodeType:   _barcodeType,
        description:   _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_outline, color: AppColors.white, size: 18),
            SizedBox(width: 8),
            Text('Product saved successfully!'),
          ]),
          backgroundColor: AppColors.teal600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ));
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.red500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _resetForm() {
    _nameCtrl.clear(); _skuCtrl.clear(); _purchaseCtrl.clear();
    _sellingCtrl.clear(); _descCtrl.clear();
    _stockCtrl.text = '0'; _alertQtyCtrl.text = '5';
    setState(() { _brand = 'In-House'; _category = ''; _autoSku = true; });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
          decoration: BoxDecoration(
            color: c.tableHeader,
            border: Border(bottom: BorderSide(color: c.border)),
          ),
          child: Row(children: [
            Icon(Icons.add_box_outlined, color: AppColors.teal600, size: 22),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Add New Product', style: AppTextStyles.h2),
              const SizedBox(height: 1),
              Text('Fill details to add a product to inventory', style: AppTextStyles.caption),
            ]),
          ]),
        ),

        // Form
        Expanded(child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              _Section('Basic Information', c),
              const SizedBox(height: 14),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 2, child: _FV('Product Name *', TextFormField(
                  controller: _nameCtrl,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                  decoration: _deco('e.g. Kanjeevaram Silk Saree', c),
                ))),
                const SizedBox(width: 16),
                Expanded(child: _FV('Brand', _DD(_brand,
                    ['In-House','Nalli','Pothys','RMKV'],
                        (v) => setState(() => _brand = v ?? _brand), c))),
                const SizedBox(width: 16),
                Expanded(child: _FV('Category *', _DD(
                    _category.isEmpty ? null : _category,
                    ['Silk Sarees','Cotton Sarees','Designer Wear','Accessories'],
                        (v) => setState(() => _category = v ?? ''), c,
                    hint: 'Select…'))),
              ]),
              const SizedBox(height: 16),
              _FV('Description (optional)', TextFormField(
                controller: _descCtrl, maxLines: 3,
                decoration: _deco('Short product description…', c),
              )),

              const SizedBox(height: 28),
              _Section('Pricing & Tax', c),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _FV('Purchase Price (₹) *', TextFormField(
                  controller: _purchaseCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                  decoration: _deco('0.00', c),
                ))),
                const SizedBox(width: 16),
                Expanded(child: _FV('Selling Price (₹) *', TextFormField(
                  controller: _sellingCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                  decoration: _deco('0.00', c),
                ))),
                const SizedBox(width: 16),
                Expanded(child: _FV('Tax Rate (GST %)', _DD(_taxType,
                    ['0','5','12','18','28'],
                        (v) => setState(() => _taxType = v ?? _taxType), c))),
              ]),

              const SizedBox(height: 28),
              _Section('Inventory & Barcode', c),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _FV('Opening Stock', TextFormField(
                  controller: _stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _deco('0', c),
                ))),
                const SizedBox(width: 16),
                Expanded(child: _FV('Alert Quantity', TextFormField(
                  controller: _alertQtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _deco('5', c),
                ))),
                const SizedBox(width: 16),
                Expanded(child: _FV('Barcode Type', _DD(_barcodeType,
                    ['CODE128','EAN-13','UPC-A'],
                        (v) => setState(() => _barcodeType = v ?? _barcodeType), c))),
              ]),
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _FV('SKU / Barcode',
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: TextFormField(
                      controller: _skuCtrl,
                      enabled: !_autoSku,
                      decoration: _deco(_autoSku ? 'Auto-generated' : 'Enter barcode', c),
                    )),
                    const SizedBox(width: 12),
                    Row(children: [
                      Checkbox(value: _autoSku,
                          onChanged: (v) => setState(() => _autoSku = v ?? true),
                          activeColor: AppColors.teal600),
                      Text('Auto Generate',
                          style: TextStyle(fontSize: 13, color: c.textSecond)),
                    ]),
                  ]),
                )),
              ]),

              const SizedBox(height: 40),
            ]),
          ),
        )),

        // Footer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: c.tableHeader,
            border: Border(top: BorderSide(color: c.border)),
          ),
          child: Row(children: [
            const Spacer(),
            OutlinedButton(
              onPressed: _resetForm,
              style: OutlinedButton.styleFrom(
                foregroundColor: c.textSecond,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                side: BorderSide(color: c.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              child: const Text('Reset'),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _saving ? null : _onSave,
              icon: _saving
                  ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_saving ? 'Saving…' : 'Save Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal600,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _Section(String title, AdaptiveColors c) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: TextStyle(fontSize: 11,
            fontWeight: FontWeight.w700, color: c.textPrimary, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Divider(height: 1, color: c.borderLight),
      ]);

  Widget _FV(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: context.colors.textSecond)),
        const SizedBox(height: 6),
        child,
      ]);

  InputDecoration _deco(String hint, AdaptiveColors c) => InputDecoration(
    hintText: hint,
    filled: true, fillColor: c.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.teal600, width: 2)),
    hintStyle: TextStyle(fontSize: 13, color: c.textMuted),
  );

  Widget _DD(String? value, List<String> items,
      ValueChanged<String?> onChanged, AdaptiveColors c, {String? hint}) =>
      Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: c.inputFill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.border),
          ),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: value,
            hint: hint != null ? Text(hint, style: TextStyle(fontSize: 14, color: c.textMuted)) : null,
            isExpanded: true, dropdownColor: c.cardBg,
            items: items.map((e) => DropdownMenuItem(value: e,
                child: Text(e, style: TextStyle(fontSize: 14, color: c.textPrimary)))).toList(),
            onChanged: onChanged,
            icon: Icon(Icons.keyboard_arrow_down, size: 18, color: c.textMuted),
            style: TextStyle(fontSize: 14, color: c.textPrimary),
          )));
}