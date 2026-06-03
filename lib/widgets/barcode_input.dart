import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';

class BarcodeInput extends StatefulWidget {
  final ValueChanged<String> onSubmit;

  const BarcodeInput({
    super.key,
    required this.onSubmit,
  });

  @override
  State<BarcodeInput> createState() => BarcodeInputState();
}

class BarcodeInputState extends State<BarcodeInput> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  void requestFocus() => _focus.requestFocus();

  void _submit() {
    final val = _ctrl.text.trim();
    if (val.isEmpty) return;

    widget.onSubmit(val);
    _ctrl.clear();
    _focus.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _focus.requestFocus(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    onSubmitted: (_) => _submit(),
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Scan Barcode or enter SKU (F2 to focus)…',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.qr_code_scanner_outlined,
                          size: 22,
                          color: c.textMuted,
                        ),
                      ),
                      prefixIconConstraints:
                      const BoxConstraints(minWidth: 48),
                      filled: true,
                      fillColor: c.inputFill,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: c.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: c.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.teal600,
                          width: 2,
                        ),
                      ),
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: c.textMuted,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: c.textPrimary,
                    ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Quick test buttons — remove after testing
          Row(
            children: [
              _quickBtn(
                '+ Banarasi Silk',
                '890123',
                widget.onSubmit,
                c,
              ),
              const SizedBox(width: 8),
              _quickBtn(
                '+ Cotton Saree',
                '890125',
                widget.onSubmit,
                c,
              ),
              const SizedBox(width: 8),
              _quickBtn(
                '+ Mysore Silk',
                '890127',
                widget.onSubmit,
                c,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _quickBtn(
    String label,
    String barcode,
    ValueChanged<String> onSubmit,
    AdaptiveColors c,
    ) {
  return OutlinedButton(
    onPressed: () => onSubmit(barcode),
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.teal600,
      side: const BorderSide(
        color: AppColors.teal600,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
    child: Text(label),
  );
}