import 'package:flutter/material.dart';
import '../core/theme.dart';

/// ─────────────────────────────────────────────────────────────
///  ADD PRODUCT SCREEN  –  Form for creating/editing products
///  Sections: Basic Info → Pricing & Tax → Inventory & Barcode
///  File: lib/screens/add_product_screen.dart
/// ─────────────────────────────────────────────────────────────
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey   = GlobalKey<FormState>();
  bool _autoSku    = true;

  // ── Form controllers ──────────────────────────────────────
  final _nameCtrl      = TextEditingController();
  final _skuCtrl       = TextEditingController();
  final _purchaseCtrl  = TextEditingController();
  final _sellingCtrl   = TextEditingController();
  final _alertQtyCtrl  = TextEditingController(text: '5');
  final _descCtrl      = TextEditingController();

  String _brand       = 'In-House';
  String _category    = '';
  String _taxType     = 'GST 5%';
  String _barcodeType = 'CODE128';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _purchaseCtrl.dispose();
    _sellingCtrl.dispose();
    _alertQtyCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_outline, color: AppColors.white, size: 18),
            SizedBox(width: 8),
            Text('Product saved successfully!'),
          ]),
          backgroundColor: AppColors.teal600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────
          _ScreenHeader(),

          // ── Form body ─────────────────────────────────────
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      title: 'Basic Information',
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _Field(
                                  label: 'Product Name *',
                                  child: TextFormField(
                                    controller: _nameCtrl,
                                    validator: (v) =>
                                    (v?.isEmpty ?? true) ? 'Required' : null,
                                    decoration: _inputDeco(
                                        'e.g. Kanjeevaram Silk Saree'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _Field(
                                  label: 'Brand',
                                  child: _DropdownField(
                                    value: _brand,
                                    items: const [
                                      'In-House', 'Nalli', 'Pothys', 'RMKV'
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _brand = v ?? _brand),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _Field(
                                  label: 'Category *',
                                  child: _DropdownField(
                                    value: _category.isEmpty ? null : _category,
                                    hint: 'Select Category…',
                                    items: const [
                                      'Silk Sarees', 'Cotton Sarees',
                                      'Designer Wear', 'Accessories'
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _category = v ?? ''),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _Field(
                            label: 'Description',
                            child: TextFormField(
                              controller: _descCtrl,
                              maxLines: 3,
                              decoration: _inputDeco(
                                  'Optional product description…'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    _Section(
                      title: 'Pricing & Tax',
                      child: Row(
                        children: [
                          Expanded(
                            child: _Field(
                              label: 'Purchase Price (₹) *',
                              child: TextFormField(
                                controller: _purchaseCtrl,
                                keyboardType: TextInputType.number,
                                validator: (v) =>
                                (v?.isEmpty ?? true) ? 'Required' : null,
                                decoration: _inputDeco('0.00'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _Field(
                              label: 'Selling Price (₹) *',
                              child: TextFormField(
                                controller: _sellingCtrl,
                                keyboardType: TextInputType.number,
                                validator: (v) =>
                                (v?.isEmpty ?? true) ? 'Required' : null,
                                decoration: _inputDeco('0.00'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _Field(
                              label: 'Tax Type',
                              child: _DropdownField(
                                value: _taxType,
                                items: const [
                                  'GST 5%', 'GST 12%', 'GST 18%', 'Tax Free'
                                ],
                                onChanged: (v) =>
                                    setState(() => _taxType = v ?? _taxType),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    _Section(
                      title: 'Inventory & Tracking',
                      child: Row(
                        children: [
                          Expanded(
                            child: _Field(
                              label: 'SKU',
                              labelSuffix: Row(
                                children: [
                                  Checkbox(
                                    value: _autoSku,
                                    onChanged: (v) =>
                                        setState(() => _autoSku = v ?? true),
                                    activeColor: AppColors.teal600,
                                    materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const Text('Auto Generate',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.gray500)),
                                ],
                              ),
                              child: TextFormField(
                                controller: _skuCtrl,
                                enabled: !_autoSku,
                                decoration: _inputDeco(
                                    _autoSku ? 'Auto-generated' : 'Enter SKU'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _Field(
                              label: 'Barcode Type',
                              child: _DropdownField(
                                value: _barcodeType,
                                items: const ['CODE128', 'EAN-13', 'UPC-A'],
                                onChanged: (v) => setState(
                                        () => _barcodeType = v ?? _barcodeType),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _Field(
                              label: 'Alert Quantity',
                              child: TextFormField(
                                controller: _alertQtyCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _inputDeco('5'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // ── Footer actions ────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.gray50,
              border: Border(top: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.barcode_reader, size: 18),
                  label: const Text('Generate & Print Barcode'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gray700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    side: const BorderSide(color: AppColors.gray300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gray700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    side: const BorderSide(color: AppColors.gray300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _onSave,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal600,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.gray50,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.teal600, width: 2)),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ScreenHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.slate50,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_box_outlined,
              color: AppColors.teal600, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New Product', style: AppTextStyles.h2),
              const SizedBox(height: 1),
              Text('Enter details to add a new product to inventory',
                  style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.gray100)),
          ),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.gray800,
                letterSpacing: 0.8),
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? labelSuffix;

  const _Field(
      {required this.label, required this.child, this.labelSuffix});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700)),
            if (labelSuffix != null) ...[
              const Spacer(),
              labelSuffix!,
            ],
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String? hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField(
      {this.value, this.hint, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: hint != null
              ? Text(hint!,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.gray400))
              : null,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: onChanged,
          style: AppTextStyles.body,
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 18, color: AppColors.gray500),
        ),
      ),
    );
  }
}
