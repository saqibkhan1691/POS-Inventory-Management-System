import 'package:flutter/material.dart';
import 'theme.dart';

/// ─────────────────────────────────────────────────────────────
///  AppColorsExt  –  lib/core/app_colors_ext.dart
///
///  Instead of hardcoded AppColors.white / AppColors.gray50,
///  screens call:
///    final c = context.colors;
///    c.cardBg      → white in light, slate-800 in dark
///    c.pageBg      → gray-50 in light, slate-900 in dark
///    c.border      → gray-200 in light, slate-700 in dark
///    c.textPrimary → gray-900 in light, slate-100 in dark
///    c.textSub     → gray-500 in light, slate-400 in dark
///    c.inputFill   → gray-50  in light, slate-700 in dark
///    c.headerBg    → gray-50  in light, slate-800 in dark
/// ─────────────────────────────────────────────────────────────

class AdaptiveColors {
  final bool isDark;
  const AdaptiveColors(this.isDark);

  Color get pageBg      => isDark ? const Color(0xFF0F172A) : AppColors.gray50;
  Color get cardBg      => isDark ? const Color(0xFF1E293B) : AppColors.white;
  Color get headerBg    => isDark ? const Color(0xFF1E293B) : AppColors.gray50;
  Color get inputFill   => isDark ? const Color(0xFF334155) : AppColors.gray50;
  Color get border      => isDark ? const Color(0xFF334155) : AppColors.gray200;
  Color get borderLight => isDark ? const Color(0xFF1E293B) : AppColors.gray100;
  Color get textPrimary => isDark ? const Color(0xFFF1F5F9) : AppColors.gray900;
  Color get textSecond  => isDark ? const Color(0xFFCBD5E1) : AppColors.gray700;
  Color get textSub     => isDark ? const Color(0xFF94A3B8) : AppColors.gray500;
  Color get textMuted   => isDark ? const Color(0xFF64748B) : AppColors.gray400;
  Color get divider     => isDark ? const Color(0xFF334155) : AppColors.gray200;
  Color get rowHover    => isDark ? const Color(0xFF1E293B) : AppColors.slate50;
  Color get tableHeader => isDark ? const Color(0xFF1E293B) : AppColors.gray50;
}

// Extension on BuildContext for easy access: context.colors
extension AdaptiveColorsExt on BuildContext {
  AdaptiveColors get colors {
    final brightness = Theme.of(this).brightness;
    return AdaptiveColors(brightness == Brightness.dark);
  }

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}