import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
///  THEME PROVIDER  –  lib/core/theme_provider.dart
///
///  ValueNotifier-based approach.
///  The global instance lives here and is imported wherever needed.
///  Settings screen calls: appThemeNotifier.value = ThemeMode.dark
///  app.dart listens with ValueListenableBuilder and rebuilds MaterialApp.
/// ─────────────────────────────────────────────────────────────

// Global singleton — import this file to access it anywhere
final ValueNotifier<ThemeMode> appThemeNotifier =
ValueNotifier(ThemeMode.light);