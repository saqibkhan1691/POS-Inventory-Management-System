import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';

/// ─────────────────────────────────────────────────────────────
///  LOGOUT CONFIRMATION DIALOG
///  Call: LogoutDialog.show(context, onConfirm: () { ... })
/// ─────────────────────────────────────────────────────────────
class LogoutDialog {
  static Future<void> show(
      BuildContext context, {
        required VoidCallback onConfirm,
      }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const _LogoutDialogWidget(),
    );
    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      onConfirm();
    }
  }
}

class _LogoutDialogWidget extends StatelessWidget {
  const _LogoutDialogWidget();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: c.cardBg,
      child: SizedBox(
        width: 360,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Top colored bar
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.red500,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
            child: Column(children: [
              // Icon
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppColors.red50,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.red100, width: 2),
                ),
                child: const Icon(Icons.logout_outlined,
                    color: AppColors.red500, size: 26),
              ),
              const SizedBox(height: 16),
              Text('Confirm Logout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      color: c.textPrimary)),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to logout?\nAll unsaved changes will be lost.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: c.textMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
            ]),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: c.tableHeader,
              border: Border(top: BorderSide(color: c.border)),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16)),
            ),
            child: Row(children: [
              // Cancel
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.textSecond,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: BorderSide(color: c.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9)),
                  textStyle: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                child: const Text('Stay'),
              )),
              const SizedBox(width: 12),
              // Confirm logout
              Expanded(child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.logout_outlined, size: 16),
                label: const Text('Yes, Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red500,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9)),
                  elevation: 0,
                  textStyle: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}