import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/payment_form.dart';
import '../core/app_colors_ext.dart';

/// ─────────────────────────────────────────────────────────────
///  PAYMENT SCREEN  –  Full-page payment UI (when accessed from
///  route, e.g. /payment).  For the billing overlay slide-in,
///  the PaymentForm widget is used directly inside BillingScreen.
///  File: lib/screens/payment_screen.dart
/// ─────────────────────────────────────────────────────────────
class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final VoidCallback? onPaymentComplete;

  const PaymentScreen({
    super.key,
    this.totalAmount = 0,
    this.onPaymentComplete,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SizedBox(
          width: 520,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gray200),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 18),
                  decoration: const BoxDecoration(
                    color: AppColors.slate900,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Payment',
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onPaymentComplete,
                        icon: const Icon(Icons.close,
                            color: AppColors.slate300, size: 22),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}