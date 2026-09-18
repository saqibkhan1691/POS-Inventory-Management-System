import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
///  APP SETTINGS NOTIFIER  –  lib/core/app_settings_notifier.dart
///  Global notifiers for Language, Date Format, Time Format
///  All screens listen to these — changes apply app-wide instantly
/// ─────────────────────────────────────────────────────────────

// Language — 'English' or 'Hindi'
final ValueNotifier<String> appLanguageNotifier =
ValueNotifier('English');

// Date format — 'DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'
final ValueNotifier<String> appDateFormatNotifier =
ValueNotifier('DD/MM/YYYY');

// Time format — '12-hour (AM/PM)' or '24-hour'
final ValueNotifier<String> appTimeFormatNotifier =
ValueNotifier('12-hour (AM/PM)');

// ── Format helpers ────────────────────────────────────────────

String formatDate(DateTime dt) {
  final fmt = appDateFormatNotifier.value;
  final d   = dt.day.toString().padLeft(2, '0');
  final m   = dt.month.toString().padLeft(2, '0');
  final y   = dt.year.toString();
  switch (fmt) {
    case 'MM/DD/YYYY': return '$m/$d/$y';
    case 'YYYY-MM-DD': return '$y-$m-$d';
    default:           return '$d/$m/$y'; // DD/MM/YYYY
  }
}

String formatTime(DateTime dt) {
  final fmt = appTimeFormatNotifier.value;
  if (fmt == '24-hour') {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  } else {
    // 12-hour AM/PM
    final h    = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m    = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $amPm';
  }
}

String formatDateTime(DateTime dt) => '${formatDate(dt)}  ${formatTime(dt)}';

// Day name helpers
String getDayName(int weekday) {
  const en = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
  const hi = ['सोम','मंगल','बुध','गुरु','शुक्र','शनि','रवि'];
  final list = appLanguageNotifier.value == 'Hindi' ? hi : en;
  return list[weekday - 1];
}

String getMonthName(int month) {
  const en = ['Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'];
  const hi = ['जन','फर','मार','अप्र','मई','जून',
    'जुल','अग','सित','अक्त','नव','दिस'];
  final list = appLanguageNotifier.value == 'Hindi' ? hi : en;
  return list[month - 1];
}