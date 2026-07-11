import '../database/dao/settings_dao.dart';
import '../models/settings_model.dart';

/// ─────────────────────────────────────────────────────────────
///  SETTINGS REPOSITORY  –  lib/repositories/settings_repository.dart
///  Single source of truth for settings.
///  Always call with userId so settings are per-user isolated.
/// ─────────────────────────────────────────────────────────────
class SettingsRepository {
  final _dao = SettingsDao();

  // Load settings for logged-in user
  // If none exist, creates defaults and returns them
  Future<SettingsModel> load(String userId) async {
    var settings = await _dao.getByUserId(userId);
    if (settings == null) {
      await _dao.insertDefault(userId);
      settings = await _dao.getByUserId(userId);
    }
    return settings!;
  }

  // Save all settings for a user
  Future<void> save(SettingsModel settings) => _dao.save(settings);

  // Quick helpers for individual sections
  Future<void> saveShop(SettingsModel s, {
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required String gstNumber,
  }) => _dao.save(s.copyWith(
    shopName:  shopName,
    ownerName: ownerName,
    phone:     phone,
    address:   address,
    gstNumber: gstNumber,
    updatedAt: DateTime.now(),
  ));

  Future<void> saveBilling(SettingsModel s, {
    required double taxPercent,
    required String currency,
    required bool discountEnabled,
    required bool autoRoundOff,
    required String invoiceType,
  }) => _dao.save(s.copyWith(
    taxPercent:      taxPercent,
    currency:        currency,
    discountEnabled: discountEnabled,
    autoRoundOff:    autoRoundOff,
    invoiceType:     invoiceType,
    updatedAt:       DateTime.now(),
  ));

  Future<void> saveInventory(SettingsModel s, {
    required bool trackStock,
    required bool autoBarcode,
    required int lowStockAlert,
    required String defaultUnit,
  }) => _dao.save(s.copyWith(
    trackStock:    trackStock,
    autoBarcode:   autoBarcode,
    lowStockAlert: lowStockAlert,
    defaultUnit:   defaultUnit,
    updatedAt:     DateTime.now(),
  ));

  Future<void> saveSync(SettingsModel s, {
    required bool autoSync,
    required bool wifiOnly,
    required bool autoBackup,
    required String syncFrequency,
  }) => _dao.save(s.copyWith(
    autoSync:      autoSync,
    wifiOnly:      wifiOnly,
    autoBackup:    autoBackup,
    syncFrequency: syncFrequency,
    updatedAt:     DateTime.now(),
  ));

  Future<void> savePrinter(SettingsModel s, {
    required String printerName,
    required String paperSize,
    required bool autoPrint,
  }) => _dao.save(s.copyWith(
    printerName: printerName,
    paperSize:   paperSize,
    autoPrint:   autoPrint,
    updatedAt:   DateTime.now(),
  ));

  Future<void> saveSystem(SettingsModel s, {
    required String language,
    required String dateFormat,
    required String timeFormat,
    required String themeMode,
  }) => _dao.save(s.copyWith(
    language:   language,
    dateFormat: dateFormat,
    timeFormat: timeFormat,
    themeMode:  themeMode,
    updatedAt:  DateTime.now(),
  ));

  // Clear on logout
  Future<void> clearUser(String userId) => _dao.deleteByUserId(userId);
}