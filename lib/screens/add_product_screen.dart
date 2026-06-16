import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';
import '../repositories/product_repository.dart';

/// ─────────────────────────────────────────────────────────────
///  ADD PRODUCT SCREEN  –  lib/screens/add_product_screen.dart
/// ─────────────────────────────────────────────────────────────
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _repo    = ProductRepository();
  final _formKey = GlobalKey<FormState>();
  bool  _saving  = false;
  bool  _autoSku = true;

  final _nameCtrl     = TextEditingController();
  final _skuCtrl      = TextEditingController();
  final _purchaseCtrl = TextEditingController();
  final _sellingCtrl  = TextEditingController();
  final _alertQtyCtrl = TextEditingController(text: '5');
  final _descCtrl     = TextEditingController();
  final _stockCtrl    = TextEditingController(text: '0');
  final _customBrandCtrl    = TextEditingController();
  final _customCategoryCtrl = TextEditingController();

  String _brand       = 'In-House';
  String _category    = '';
  String _taxType     = '5';
  String _barcodeType = 'CODE128';
  bool   _showCustomBrand    = false;
  bool   _showCustomCategory = false;

  // Dynamic lists — user can add new brands/categories
  final List<String> _extraBrands     = [];
  final List<String> _extraCategories = [];

  List<String> get _allBrands =>
      ['In-House','Nalli','Pothys','RMKV', ..._extraBrands, 'Other'];

  List<String> get _allCategories =>
      ['Silk Sarees','Cotton Sarees','Designer Wear',
        'Accessories', ..._extraCategories, 'Other'];

  @override
  void dispose() {
    for (final c in [_nameCtrl, _skuCtrl, _purchaseCtrl, _sellingCtrl,
      _alertQtyCtrl, _descCtrl, _stockCtrl,
      _customBrandCtrl, _customCategoryCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  String _generateBarcode() {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    return ts.substring(ts.length - 8);
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_category.isEmpty || _category == 'Other') {
      _snack('Please select or enter a category', AppColors.orange700);
      return;
    }

    // ── Numeric validation ─────────────────────────────────────
    final purchasePrice = double.tryParse(_purchaseCtrl.text);
    final sellingPrice  = double.tryParse(_sellingCtrl.text);
    final stock         = int.tryParse(_stockCtrl.text);
    final alertQty      = int.tryParse(_alertQtyCtrl.text);

    if (purchasePrice == null || sellingPrice == null) {
      _snack('Please enter valid numbers for prices', AppColors.red500);
      return;
    }
    if (purchasePrice < 0 || sellingPrice < 0) {
      _snack('Price cannot be negative', AppColors.red500);
      return;
    }
    if (stock == null || alertQty == null) {
      _snack('Please enter valid whole numbers for Stock / Alert Qty', AppColors.red500);
      return;
    }
    if (stock < 0) {
      _snack('Stock cannot be negative', AppColors.red500);
      return;
    }
    if (alertQty < 0) {
      _snack('Alert quantity cannot be negative', AppColors.red500);
      return;
    }

    setState(() => _saving = true);
    try {
      final barcode = _autoSku ? _generateBarcode() : _skuCtrl.text.trim();
      await _repo.addProduct(
        name:          _nameCtrl.text.trim(),
        barcode:       barcode,
        category:      _category,
        brand:         _brand == 'Other' ? 'In-House' : _brand,
        purchasePrice: purchasePrice,
        sellingPrice:  sellingPrice,
        taxRate:       (double.tryParse(_taxType) ?? 5) / 100,
        stock:         stock,
        alertQty:      alertQty,
        barcodeType:   _barcodeType,
        description:   _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
      if (mounted) {
        _snack('Product saved successfully!', AppColors.teal600);
        _resetForm();
      }
    } catch (e) {
      if (mounted) _snack('Error: $e', AppColors.red500);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _resetForm() {
    _nameCtrl.clear(); _skuCtrl.clear();
    _purchaseCtrl.clear(); _sellingCtrl.clear();
    _descCtrl.clear(); _customBrandCtrl.clear();
    _customCategoryCtrl.clear();
    _stockCtrl.text   = '0';
    _alertQtyCtrl.text = '5';
    setState(() {
      _brand    = 'In-House';
      _category = '';
      _autoSku  = true;
      _showCustomBrand    = false;
      _showCustomCategory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        // ── Header ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
          decoration: BoxDecoration(
            color: c.tableHeader,
            border: Border(bottom: BorderSide(color: c.border)),
          ),
          child: Row(children: [
            const Icon(Icons.add_box_outlined,
                color: AppColors.teal600, size: 22),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Add New Product', style: AppTextStyles.h2),
              const SizedBox(height: 1),
              Text('Fill details to add a product to inventory',
                  style: AppTextStyles.caption),
            ]),
          ]),
        ),

        // ── Form ───────────────────────────────────────────
        Expanded(child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _sectionTitle('Basic Information', c),
                  const SizedBox(height: 14),

                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 2, child: _fv('Product Name *',
                        TextFormField(
                          controller: _nameCtrl,
                          validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Required' : null,
                          decoration: _deco('e.g. Kanjeevaram Silk Saree', c),
                          style: TextStyle(color: c.textPrimary),
                        ))),
                    const SizedBox(width: 16),
                    // Brand with Other support
                    Expanded(child: _fv('Brand', _buildBrandField(c))),
                    const SizedBox(width: 16),
                    // Category with Other support
                    Expanded(child: _fv('Category *', _buildCategoryField(c))),
                  ]),

                  const SizedBox(height: 16),
                  _fv('Description (optional)', TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: _deco('Short product description…', c),
                    style: TextStyle(color: c.textPrimary),
                  )),

                  const SizedBox(height: 28),
                  _sectionTitle('Pricing & Tax', c),
                  const SizedBox(height: 14),

                  Row(children: [
                    Expanded(child: _fv('Purchase Price (₹) *',
                        TextFormField(
                          controller: _purchaseCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                          ],
                          validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Required' : null,
                          decoration: _deco('0.00', c),
                          style: TextStyle(color: c.textPrimary),
                        ))),
                    const SizedBox(width: 16),
                    Expanded(child: _fv('Selling Price (₹) *',
                        TextFormField(
                          controller: _sellingCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                          ],
                          validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Required' : null,
                          decoration: _deco('0.00', c),
                          style: TextStyle(color: c.textPrimary),
                        ))),
                    const SizedBox(width: 16),
                    Expanded(child: _fv('Tax Rate (GST %)',
                        _dd(_taxType, ['0','5','12','18','28'],
                                (v) => setState(() => _taxType = v ?? _taxType), c))),
                  ]),

                  const SizedBox(height: 28),
                  _sectionTitle('Inventory & Barcode', c),
                  const SizedBox(height: 14),

                  Row(children: [
                    Expanded(child: _fv('Opening Stock',
                        TextFormField(
                          controller: _stockCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                          ],
                          decoration: _deco('0', c),
                          style: TextStyle(color: c.textPrimary),
                        ))),
                    const SizedBox(width: 16),
                    Expanded(child: _fv('Alert Quantity',
                        TextFormField(
                          controller: _alertQtyCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                          ],
                          decoration: _deco('5', c),
                          style: TextStyle(color: c.textPrimary),
                        ))),
                    const SizedBox(width: 16),
                    Expanded(child: _fv('Barcode Type',
                        _dd(_barcodeType, ['CODE128','EAN-13','UPC-A'],
                                (v) => setState(() => _barcodeType = v ?? _barcodeType),
                            c))),
                  ]),

                  const SizedBox(height: 16),
                  _fv('SKU / Barcode',
                    Row(children: [
                      Expanded(child: TextFormField(
                        controller: _skuCtrl,
                        enabled: !_autoSku,
                        decoration: _deco(
                            _autoSku ? 'Auto-generated' : 'Enter barcode', c),
                        style: TextStyle(color: c.textPrimary),
                      )),
                      const SizedBox(width: 12),
                      Row(children: [
                        Checkbox(
                          value: _autoSku,
                          onChanged: (v) =>
                              setState(() => _autoSku = v ?? true),
                          activeColor: AppColors.teal600,
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                        ),
                        Text('Auto Generate',
                            style: TextStyle(
                                fontSize: 13, color: c.textSecond)),
                      ]),
                    ]),
                  ),

                  const SizedBox(height: 40),
                ]),
          ),
        )),

        // ── Footer ─────────────────────────────────────────
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
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                side: BorderSide(color: c.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              child: const Text('Reset'),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _saving ? null : _onSave,
              icon: _saving
                  ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.white))
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_saving ? 'Saving…' : 'Save Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal600,
                foregroundColor: AppColors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Brand field with "Other" support ──────────────────────
  Widget _buildBrandField(AdaptiveColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dd(
          _showCustomBrand ? 'Other' : _brand,
          _allBrands,
              (v) {
            if (v == 'Other') {
              setState(() => _showCustomBrand = true);
            } else {
              setState(() {
                _showCustomBrand = false;
                _brand = v ?? _brand;
              });
            }
          },
          c,
        ),
        if (_showCustomBrand) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _customBrandCtrl,
            autofocus: true,
            decoration: _deco('Type new brand name…', c),
            style: TextStyle(color: c.textPrimary),
            onSubmitted: (v) {
              final val = v.trim();
              if (val.isNotEmpty) {
                setState(() {
                  _extraBrands.add(val);
                  _brand = val;
                  _showCustomBrand = false;
                  _customBrandCtrl.clear();
                });
              }
            },
          ),
          const SizedBox(height: 6),
          Text('Press Enter to confirm',
              style: TextStyle(fontSize: 11, color: c.textMuted)),
        ],
      ],
    );
  }

  // ── Category field with "Other" support ───────────────────
  Widget _buildCategoryField(AdaptiveColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dd(
          _showCustomCategory
              ? 'Other'
              : (_category.isEmpty ? null : _category),
          _allCategories,
              (v) {
            if (v == 'Other') {
              setState(() {
                _showCustomCategory = true;
                _category = 'Other';
              });
            } else {
              setState(() {
                _showCustomCategory = false;
                _category = v ?? '';
              });
            }
          },
          c,
          hint: 'Select…',
        ),
        if (_showCustomCategory) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _customCategoryCtrl,
            autofocus: true,
            decoration: _deco('Type new category name…', c),
            style: TextStyle(color: c.textPrimary),
            onSubmitted: (v) {
              final val = v.trim();
              if (val.isNotEmpty) {
                setState(() {
                  _extraCategories.add(val);
                  _category = val;
                  _showCustomCategory = false;
                  _customCategoryCtrl.clear();
                });
              }
            },
          ),
          const SizedBox(height: 6),
          Text('Press Enter to confirm',
              style: TextStyle(fontSize: 11, color: c.textMuted)),
        ],
      ],
    );
  }

  // ── Reusable helpers ───────────────────────────────────────
  Widget _sectionTitle(String title, AdaptiveColors c) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: c.textPrimary, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Divider(height: 1, color: c.borderLight),
      ]);

  Widget _fv(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: context.colors.textSecond)),
        const SizedBox(height: 6),
        child,
      ]);

  InputDecoration _deco(String hint, AdaptiveColors c) => InputDecoration(
    hintText: hint,
    filled: true, fillColor: c.inputFill,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.teal600, width: 2)),
    hintStyle: TextStyle(fontSize: 13, color: c.textMuted),
  );

  Widget _dd(String? value, List<String> items,
      ValueChanged<String?> onChanged, AdaptiveColors c,
      {String? hint}) =>
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: c.inputFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: hint != null
                ? Text(hint,
                style: TextStyle(fontSize: 14, color: c.textMuted))
                : null,
            isExpanded: true,
            dropdownColor: c.cardBg,
            items: items
                .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e,
                    style: TextStyle(
                        fontSize: 14, color: c.textPrimary))))
                .toList(),
            onChanged: onChanged,
            icon: Icon(Icons.keyboard_arrow_down,
                size: 18, color: c.textMuted),
            style: TextStyle(fontSize: 14, color: c.textPrimary),
          ),
        ),
      );
}