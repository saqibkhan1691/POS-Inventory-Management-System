import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
///  APP LOCALIZATIONS  –  lib/core/app_localizations.dart
///  English / Hindi UI translation
/// ─────────────────────────────────────────────────────────────
final ValueNotifier<String> appLanguageNotifier = ValueNotifier('English');

class AppLocalizations {
  final String language;
  const AppLocalizations(this.language);
  bool get isHindi => language == 'Hindi';

  // Sidebar
  String get billing          => isHindi ? 'बिलिंग'                    : 'Billing';
  String get addProduct       => isHindi ? 'उत्पाद जोड़ें'              : 'Add Product';
  String get inventory        => isHindi ? 'इन्वेंटरी'                 : 'Inventory';
  String get transactions     => isHindi ? 'लेन-देन'                   : 'Transactions';
  String get reports          => isHindi ? 'रिपोर्ट'                   : 'Reports';
  String get settings         => isHindi ? 'सेटिंग्स'                  : 'Settings';
  String get logout           => isHindi ? 'लॉग आउट'                  : 'Logout';

  // TopBar
  String get searchHint       => isHindi ? 'उत्पाद, बिल खोजें…'        : 'Search products, bills (F3)…';
  String get online           => isHindi ? 'ऑनलाइन'                   : 'Online';
  String get mainBranch       => isHindi ? 'मुख्य शाखा'                : 'Main Branch';
  String get adminUser        => isHindi ? 'एडमिन यूजर'               : 'Admin User';

  // Billing
  String get scanBarcode      => isHindi ? 'बारकोड स्कैन करें…'        : 'Scan barcode or type product name…';
  String get addItem          => isHindi ? 'आइटम जोड़ें'               : 'Add Item';
  String get cartEmpty        => isHindi ? 'कार्ट खाली है। उत्पाद स्कैन करें।' : 'Cart is empty. Scan products to add.';
  String get billSummary      => isHindi ? 'बिल सारांश'                : 'Bill Summary';
  String get itemsInCart      => isHindi ? 'कार्ट में आइटम'             : 'Items in cart';
  String get subtotal         => isHindi ? 'उप-कुल'                   : 'Subtotal';
  String get discountPct      => isHindi ? 'छूट (%)'                  : 'Discount (%)';
  String get taxGst           => isHindi ? 'कर (GST)'                 : 'Tax (GST)';
  String get finalTotal       => isHindi ? 'कुल राशि'                 : 'FINAL TOTAL';
  String get proceedPayment   => isHindi ? 'भुगतान करें'               : 'Proceed to Payment';
  String get productDetails   => isHindi ? 'उत्पाद विवरण'              : 'Product Details';
  String get qty              => isHindi ? 'मात्रा'                   : 'Qty';
  String get price            => isHindi ? 'मूल्य'                    : 'Price';
  String get total            => isHindi ? 'कुल'                     : 'Total';

  // Inventory
  String get inventoryMgmt    => isHindi ? 'इन्वेंटरी प्रबंधन'         : 'Inventory Management';
  String get viewManageStock  => isHindi ? 'अपना स्टॉक देखें और प्रबंधित करें' : 'View and manage your product stock';
  String get searchProduct    => isHindi ? 'उत्पाद नाम, बारकोड खोजें…' : 'Search by product name, barcode…';
  String get allCategories    => isHindi ? 'सभी श्रेणियां'              : 'All Categories';
  String get allStatus        => isHindi ? 'सभी स्थिति'                : 'All Status';
  String get inStock          => isHindi ? 'स्टॉक में'                 : 'In Stock';
  String get lowStock         => isHindi ? 'कम स्टॉक'                 : 'Low Stock';
  String get outOfStock       => isHindi ? 'स्टॉक खत्म'               : 'Out of Stock';
  String get productInfo      => isHindi ? 'उत्पाद जानकारी'            : 'Product Info';
  String get barcodeSku       => isHindi ? 'बारकोड / SKU'              : 'Barcode / SKU';
  String get stock            => isHindi ? 'स्टॉक'                    : 'Stock';
  String get status           => isHindi ? 'स्थिति'                   : 'Status';
  String get actions          => isHindi ? 'कार्रवाई'                  : 'Actions';
  String get refresh          => isHindi ? 'ताज़ा करें'                 : 'Refresh';
  String get noProductsFound  => isHindi ? 'कोई उत्पाद नहीं मिला'       : 'No products found.';

  // Add Product
  String get addNewProduct    => isHindi ? 'नया उत्पाद जोड़ें'          : 'Add New Product';
  String get fillDetails      => isHindi ? 'इन्वेंटरी में उत्पाद जोड़ने के लिए विवरण भरें' : 'Fill details to add a product to inventory';
  String get productName      => isHindi ? 'उत्पाद का नाम'             : 'Product Name';
  String get brand            => isHindi ? 'ब्रांड'                   : 'Brand';
  String get category         => isHindi ? 'श्रेणी'                   : 'Category';
  String get description      => isHindi ? 'विवरण (वैकल्पिक)'          : 'Description (optional)';
  String get purchasePrice    => isHindi ? 'खरीद मूल्य (₹)'           : 'Purchase Price (₹)';
  String get sellingPrice     => isHindi ? 'बिक्री मूल्य (₹)'          : 'Selling Price (₹)';
  String get taxRate          => isHindi ? 'कर दर (GST %)'            : 'Tax Rate (GST %)';
  String get openingStock     => isHindi ? 'प्रारंभिक स्टॉक'           : 'Opening Stock';
  String get alertQty         => isHindi ? 'अलर्ट मात्रा'              : 'Alert Quantity';
  String get barcodeType      => isHindi ? 'बारकोड प्रकार'             : 'Barcode Type';
  String get saveProduct      => isHindi ? 'उत्पाद सहेजें'             : 'Save Product';
  String get reset            => isHindi ? 'रीसेट'                    : 'Reset';
  String get autoGenerate     => isHindi ? 'स्वतः जनरेट'              : 'Auto Generate';

  // Payment
  String get payment          => isHindi ? 'भुगतान'                   : 'Payment';
  String get amountToPay      => isHindi ? 'भुगतान राशि'               : 'Amount to Pay';
  String get selectMethod     => isHindi ? 'भुगतान विधि चुनें'         : 'SELECT METHOD';
  String get cash             => isHindi ? 'नकद'                     : 'Cash';
  String get upi              => isHindi ? 'UPI'                     : 'UPI';
  String get card             => isHindi ? 'कार्ड'                    : 'Card';
  String get amountReceived   => isHindi ? 'प्राप्त राशि'              : 'AMOUNT RECEIVED';
  String get change           => isHindi ? 'वापसी:'                   : 'Change:';
  String get confirmPrint     => isHindi ? 'पुष्टि करें और प्रिंट करें' : 'Confirm & Print Bill';

  // Transaction
  String get transactionHistory => isHindi ? 'लेन-देन इतिहास'         : 'Transaction History';
  String get exportCsv        => isHindi ? 'CSV निर्यात'               : 'Export CSV';
  String get customer         => isHindi ? 'ग्राहक'                   : 'Customer';
  String get items            => isHindi ? 'आइटम'                    : 'Items';
  String get amount           => isHindi ? 'राशि'                    : 'Amount';
  String get completed        => isHindi ? 'पूर्ण'                    : 'Completed';
  String get refunded         => isHindi ? 'वापसी'                   : 'Refunded';
  String get pendingStr       => isHindi ? 'लंबित'                   : 'Pending';
  String get today            => isHindi ? 'आज'                      : 'Today';
  String get yesterday        => isHindi ? 'कल'                      : 'Yesterday';
  String get last7Days        => isHindi ? 'पिछले 7 दिन'              : 'Last 7 Days';
  String get last30Days       => isHindi ? 'पिछले 30 दिन'             : 'Last 30 Days';
  String get allTime          => isHindi ? 'सभी समय'                  : 'All Time';
  String get customDateRange  => isHindi ? 'कस्टम तिथि'               : 'Custom Date Range';

  // Settings
  String get systemPrefs      => isHindi ? 'सिस्टम प्राथमिकताएं'       : 'System Preferences';
  String get customizeInterface => isHindi ? 'इंटरफ़ेस और स्थानीयकरण सेटिंग्स अनुकूलित करें' : 'Customize the interface and localization settings.';
  String get interfaceTheme   => isHindi ? 'इंटरफ़ेस थीम'              : 'Interface Theme';
  String get lightMode        => isHindi ? 'लाइट मोड'                 : 'Light Mode';
  String get darkMode         => isHindi ? 'डार्क मोड'               : 'Dark Mode';
  String get language         => isHindi ? 'भाषा'                    : 'Language';
  String get dateFormat       => isHindi ? 'तिथि प्रारूप'              : 'Date Format';
  String get timeFormat       => isHindi ? 'समय प्रारूप'              : 'Time Format';
  String get saveChanges      => isHindi ? 'परिवर्तन सहेजें'           : 'Save Changes';

  // Common
  String get save             => isHindi ? 'सहेजें'                   : 'Save';
  String get cancel           => isHindi ? 'रद्द करें'               : 'Cancel';
  String get delete           => isHindi ? 'हटाएं'                   : 'Delete';
  String get edit             => isHindi ? 'संपादित करें'             : 'Edit';
  String get noDataFound      => isHindi ? 'कोई डेटा नहीं मिला'       : 'No data found.';
  String get showing          => isHindi ? 'दिखा रहे हैं'             : 'Showing';
  String get of               => isHindi ? 'में से'                   : 'of';
  String get results          => isHindi ? 'परिणाम'                  : 'results';
  String get transactions_    => isHindi ? 'लेन-देन'                  : 'transactions';
}

extension LocalizationExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations(appLanguageNotifier.value);
}