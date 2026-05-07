import 'package:flutter/material.dart';
import '../core/theme.dart';

/// ─────────────────────────────────────────────────────────────
///  TOP BAR  –  Search + status + user info
///  Height: 64 px, white surface with bottom border/shadow
/// ─────────────────────────────────────────────────────────────
class AppTopBar extends StatefulWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends State<AppTopBar> {
  late String _timeStr;

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Refresh every minute
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 1));
      if (mounted) setState(_updateTime);
      return mounted;
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    final m = now.minute.toString().padLeft(2, '0');
    _timeStr =
    '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}  $h:$m $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      //color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
        boxShadow: [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          // ── Search ──────────────────────────────────────
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SizedBox(
                height: 38,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products, bills (F3)…',
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.gray400),
                    filled: true,
                    fillColor: AppColors.gray100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.teal600, width: 1.5),
                    ),
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ),

          const Spacer(),

          // ── Online indicator ────────────────────────────
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.green500,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.green500.withOpacity(0.5), blurRadius: 6)],
                ),
              ),
              const SizedBox(width: 6),
              Text('Online',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.gray600, fontWeight: FontWeight.w500)),
            ],
          ),

          const SizedBox(width: 20),

          // ── DateTime ────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              _timeStr,
              style: const TextStyle(fontSize: 12.5, color: AppColors.gray500, fontWeight: FontWeight.w500),
            ),
          ),

          const SizedBox(width: 16),

          // ── User info ───────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Admin User',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                    Text('Main Branch',
                        style: TextStyle(fontSize: 11, color: AppColors.gray400)),
                  ],
                ),
                const SizedBox(width: 10),
                const Icon(Icons.account_circle_outlined,
                    size: 32, color: AppColors.gray400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
