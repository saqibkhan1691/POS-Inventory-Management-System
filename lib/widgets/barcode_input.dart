import 'package:flutter/material.dart';
import '../core/theme.dart';

/// ─────────────────────────────────────────────────────────────
///  BARCODE INPUT  –  Full-width scan bar with Add Item button
///  Used in: BillingScreen (top area)
/// ─────────────────────────────────────────────────────────────
class BarcodeInput extends StatefulWidget {
  /// Called when user submits barcode (Enter or button press)
  final ValueChanged<String> onSubmit;

  const BarcodeInput({super.key, required this.onSubmit});

  @override
  State<BarcodeInput> createState() => BarcodeInputState();
}

class BarcodeInputState extends State<BarcodeInput> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  /// Public: let parent focus this field (e.g. after payment)
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Row(
        children: [
          // Input field
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
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.qr_code_scanner_outlined, size: 22, color: AppColors.gray400),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 48),
                  filled: true,
                  fillColor: AppColors.gray50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.gray300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.gray300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.teal600, width: 2),
                  ),
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.gray400),
                ),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Add Item button
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
        ],
      ),
    );
  }
}
