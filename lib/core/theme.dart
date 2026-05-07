import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
///  APP THEME  –  Shree Sarees Desktop POS
///  Teal-on-Slate palette, desktop-optimised typography & spacing
/// ─────────────────────────────────────────────────────────────
class AppColors {
  // Brand
  static const teal600    = Color(0xFF0D9488);
  static const teal700    = Color(0xFF0F766E);
  static const teal50     = Color(0xFFF0FDFA);
  static const teal100    = Color(0xFFCCFBF1);

  // Slate
  static const slate900   = Color(0xFF0F172A);
  static const slate950   = Color(0xFF020617);
  static const slate800   = Color(0xFF1E293B);
  static const slate600   = Color(0xFF475569);
  static const slate500   = Color(0xFF64748B);
  static const slate400   = Color(0xFF94A3B8);
  static const slate300   = Color(0xFFCBD5E1);
  static const slate100   = Color(0xFFF1F5F9);
  static const slate50    = Color(0xFFF8FAFC);

  // Gray
  static const gray50     = Color(0xFFF9FAFB);
  static const gray100    = Color(0xFFF3F4F6);
  static const gray200    = Color(0xFFE5E7EB);
  static const gray300    = Color(0xFFD1D5DB);
  static const gray400    = Color(0xFF9CA3AF);
  static const gray500    = Color(0xFF6B7280);
  static const gray600    = Color(0xFF4B5563);
  static const gray700    = Color(0xFF374151);
  static const gray800    = Color(0xFF1F2937);
  static const gray900    = Color(0xFF111827);

  // Status
  static const green500   = Color(0xFF22C55E);
  static const green100   = Color(0xFFDCFCE7);
  static const green700   = Color(0xFF15803D);
  static const orange100  = Color(0xFFFFEDD5);
  static const orange700  = Color(0xFFC2410C);
  static const red50      = Color(0xFFFEF2F2);
  static const red100     = Color(0xFFFEE2E2);
  static const red500     = Color(0xFFEF4444);
  static const red700     = Color(0xFFB91C1C);

  // White / surface
  static const white      = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const fontFamily = 'Roboto';  // or use GoogleFonts in pubspec

  static const TextStyle h1 = TextStyle(
      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gray900, letterSpacing: -0.3);
  static const TextStyle h2 = TextStyle(
      fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900);
  static const TextStyle h3 = TextStyle(
      fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray800);
  static const TextStyle body = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.gray700);
  static const TextStyle bodyBold = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800);
  static const TextStyle caption = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.gray500);
  static const TextStyle captionBold = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray600, letterSpacing: 0.6);
  static const TextStyle mono = TextStyle(
      fontSize: 13, fontFamily: 'monospace', color: AppColors.gray600);
  static const TextStyle huge = TextStyle(
      fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.teal600);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: ColorScheme.light(
        primary: AppColors.teal600,
        onPrimary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.gray900,
        background: AppColors.gray50,
      ),
      scaffoldBackgroundColor: AppColors.gray50,
      dividerColor: AppColors.gray200,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.teal600, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(color: AppColors.gray400, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal600,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          elevation: 1,
        ),
      ),
    );
  }
}
