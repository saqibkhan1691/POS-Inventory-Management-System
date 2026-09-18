import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';
import '../core/app_settings_notifier.dart';
import '../core/app_localizations.dart';

/// ─────────────────────────────────────────────────────────────
///  TOP BAR — Updated with live Date/Time format + Language
/// ─────────────────────────────────────────────────────────────
class AppTopBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<String>? onSearch;
  const AppTopBar({super.key, this.onSearch});
  @override
  Size get preferredSize => const Size.fromHeight(64);
  @override
  State<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends State<AppTopBar> {
  final _searchCtrl = TextEditingController();
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _startClock();
    // Rebuild when format changes
    appDateFormatNotifier.addListener(_rebuild);
    appTimeFormatNotifier.addListener(_rebuild);
    appLanguageNotifier.addListener(_rebuild);
  }

  void _rebuild() { if (mounted) setState(() {}); }

  void _startClock() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (!mounted) return false;
      setState(() => _now = DateTime.now());
      return mounted;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    appDateFormatNotifier.removeListener(_rebuild);
    appTimeFormatNotifier.removeListener(_rebuild);
    appLanguageNotifier.removeListener(_rebuild);
    super.dispose();
  }

  String get _dateTimeStr {
    final day   = getDayName(_now.weekday);
    final month = getMonthName(_now.month);
    final date  = '${_now.day} $month';
    final time  = formatTime(_now);
    return '$day, $date  $time';
  }

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final l10n = context.l10n;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: c.cardBg,
        border: Border(bottom: BorderSide(color: c.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 4, offset: const Offset(0, 1))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        // Search
        Expanded(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SizedBox(height: 38,
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (v) {
                widget.onSearch?.call(v.trim());
                _searchCtrl.clear();
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: Icon(Icons.search, size: 18, color: c.textMuted),
                filled: true, fillColor: c.inputFill,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppColors.teal600, width: 1.5)),
                hintStyle: TextStyle(fontSize: 13, color: c.textMuted),
              ),
              style: TextStyle(fontSize: 13, color: c.textPrimary),
            ),
          ),
        )),
        const Spacer(),

        // Online status
        Row(children: [
          Container(width: 9, height: 9,
              decoration: BoxDecoration(
                color: AppColors.green500,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                    color: AppColors.green500.withOpacity(0.5),
                    blurRadius: 6)],
              )),
          const SizedBox(width: 6),
          Text(l10n.online, style: TextStyle(
              fontSize: 13, color: c.textSecond,
              fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(width: 20),

        // Date & Time — live, respects format settings
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: c.inputFill,
              borderRadius: BorderRadius.circular(7)),
          child: Text(_dateTimeStr, style: TextStyle(
              fontSize: 12.5, color: c.textSub,
              fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 16),

        // User info
        Row(children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.adminUser, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: c.textPrimary)),
                Text(l10n.mainBranch, style: TextStyle(
                    fontSize: 11, color: c.textMuted)),
              ]),
          const SizedBox(width: 10),
          Icon(Icons.account_circle_outlined, size: 32, color: c.textMuted),
        ]),
      ]),
    );
  }
}