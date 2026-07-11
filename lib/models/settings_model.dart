/// ─────────────────────────────────────────────────────────────
///  SETTINGS MODEL  –  lib/models/settings_model.dart
/// ─────────────────────────────────────────────────────────────
class SettingsModel {
  final int?   id;
  final String userId;

  // Shop
  final String shopName;
  final String ownerName;
  final String phone;
  final String address;
  final String gstNumber;

  // Billing
  final String currency;
  final double taxPercent;
  final bool   discountEnabled;
  final bool   autoRoundOff;
  final String invoiceType;

  // Inventory
  final bool   trackStock;
  final bool   autoBarcode;
  final int    lowStockAlert;
  final String defaultUnit;

  // Sync
  final bool   autoSync;
  final bool   wifiOnly;
  final bool   autoBackup;
  final String syncFrequency;

  // Printer
  final String printerName;
  final String paperSize;
  final bool   autoPrint;

  // System
  final String language;
  final String dateFormat;
  final String timeFormat;
  final String themeMode;

  final DateTime updatedAt;

  const SettingsModel({
    this.id,
    required this.userId,
    this.shopName        = 'My Shop',
    this.ownerName       = 'Admin',
    this.phone           = '',
    this.address         = '',
    this.gstNumber       = '',
    this.currency        = '₹ (INR) - Indian Rupee',
    this.taxPercent      = 5.0,
    this.discountEnabled = true,
    this.autoRoundOff    = true,
    this.invoiceType     = 'thermal',
    this.trackStock      = true,
    this.autoBarcode     = true,
    this.lowStockAlert   = 10,
    this.defaultUnit     = 'Pieces (pcs)',
    this.autoSync        = true,
    this.wifiOnly        = true,
    this.autoBackup      = false,
    this.syncFrequency   = 'Every 5 minutes',
    this.printerName     = 'No Printer',
    this.paperSize       = '80mm (Standard Receipt)',
    this.autoPrint       = true,
    this.language        = 'English',
    this.dateFormat      = 'DD/MM/YYYY',
    this.timeFormat      = '12-hour (AM/PM)',
    this.themeMode       = 'light',
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id':          userId,
    'shop_name':        shopName,
    'owner_name':       ownerName,
    'phone':            phone,
    'address':          address,
    'gst_number':       gstNumber,
    'currency':         currency,
    'tax_percent':      taxPercent,
    'discount_enabled': discountEnabled ? 1 : 0,
    'auto_round_off':   autoRoundOff    ? 1 : 0,
    'invoice_type':     invoiceType,
    'track_stock':      trackStock      ? 1 : 0,
    'auto_barcode':     autoBarcode     ? 1 : 0,
    'low_stock_alert':  lowStockAlert,
    'default_unit':     defaultUnit,
    'auto_sync':        autoSync        ? 1 : 0,
    'wifi_only':        wifiOnly        ? 1 : 0,
    'auto_backup':      autoBackup      ? 1 : 0,
    'sync_frequency':   syncFrequency,
    'printer_name':     printerName,
    'paper_size':       paperSize,
    'auto_print':       autoPrint       ? 1 : 0,
    'language':         language,
    'date_format':      dateFormat,
    'time_format':      timeFormat,
    'theme_mode':       themeMode,
    'updated_at':       updatedAt.toIso8601String(),
  };

  factory SettingsModel.fromMap(Map<String, dynamic> m) => SettingsModel(
    id:              m['id']              as int?,
    userId:          m['user_id']         as String,
    shopName:        m['shop_name']       as String,
    ownerName:       m['owner_name']      as String,
    phone:           m['phone']           as String,
    address:         m['address']         as String,
    gstNumber:       m['gst_number']      as String,
    currency:        m['currency']        as String,
    taxPercent:      (m['tax_percent']    as num).toDouble(),
    discountEnabled: (m['discount_enabled'] as int) == 1,
    autoRoundOff:    (m['auto_round_off']   as int) == 1,
    invoiceType:     m['invoice_type']    as String,
    trackStock:      (m['track_stock']    as int) == 1,
    autoBarcode:     (m['auto_barcode']   as int) == 1,
    lowStockAlert:   m['low_stock_alert'] as int,
    defaultUnit:     m['default_unit']    as String,
    autoSync:        (m['auto_sync']      as int) == 1,
    wifiOnly:        (m['wifi_only']      as int) == 1,
    autoBackup:      (m['auto_backup']    as int) == 1,
    syncFrequency:   m['sync_frequency']  as String,
    printerName:     m['printer_name']    as String,
    paperSize:       m['paper_size']      as String,
    autoPrint:       (m['auto_print']     as int) == 1,
    language:        m['language']        as String,
    dateFormat:      m['date_format']     as String,
    timeFormat:      m['time_format']     as String,
    themeMode:       m['theme_mode']      as String,
    updatedAt:       DateTime.parse(m['updated_at'] as String),
  );

  SettingsModel copyWith({
    int? id, String? userId,
    String? shopName, String? ownerName, String? phone,
    String? address, String? gstNumber, String? currency,
    double? taxPercent, bool? discountEnabled, bool? autoRoundOff,
    String? invoiceType, bool? trackStock, bool? autoBarcode,
    int? lowStockAlert, String? defaultUnit, bool? autoSync,
    bool? wifiOnly, bool? autoBackup, String? syncFrequency,
    String? printerName, String? paperSize, bool? autoPrint,
    String? language, String? dateFormat, String? timeFormat,
    String? themeMode, DateTime? updatedAt,
  }) => SettingsModel(
    id:              id              ?? this.id,
    userId:          userId          ?? this.userId,
    shopName:        shopName        ?? this.shopName,
    ownerName:       ownerName       ?? this.ownerName,
    phone:           phone           ?? this.phone,
    address:         address         ?? this.address,
    gstNumber:       gstNumber       ?? this.gstNumber,
    currency:        currency        ?? this.currency,
    taxPercent:      taxPercent      ?? this.taxPercent,
    discountEnabled: discountEnabled ?? this.discountEnabled,
    autoRoundOff:    autoRoundOff    ?? this.autoRoundOff,
    invoiceType:     invoiceType     ?? this.invoiceType,
    trackStock:      trackStock      ?? this.trackStock,
    autoBarcode:     autoBarcode     ?? this.autoBarcode,
    lowStockAlert:   lowStockAlert   ?? this.lowStockAlert,
    defaultUnit:     defaultUnit     ?? this.defaultUnit,
    autoSync:        autoSync        ?? this.autoSync,
    wifiOnly:        wifiOnly        ?? this.wifiOnly,
    autoBackup:      autoBackup      ?? this.autoBackup,
    syncFrequency:   syncFrequency   ?? this.syncFrequency,
    printerName:     printerName     ?? this.printerName,
    paperSize:       paperSize       ?? this.paperSize,
    autoPrint:       autoPrint       ?? this.autoPrint,
    language:        language        ?? this.language,
    dateFormat:      dateFormat      ?? this.dateFormat,
    timeFormat:      timeFormat      ?? this.timeFormat,
    themeMode:       themeMode       ?? this.themeMode,
    updatedAt:       updatedAt       ?? this.updatedAt,
  );
}