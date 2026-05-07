import 'package:flutter/material.dart';
import '../core/theme.dart';

/// ─────────────────────────────────────────────────────────────
///  SETTINGS SCREEN  –  lib/screens/settings_screen.dart
///  Tabbed settings: Store Info | Receipt | Tax & Pricing |
///                   Sync & Backup | Security
/// ─────────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _tab = 0;

  static const _tabs = [
    (icon: Icons.store_outlined,          label: 'Store Info'),
    (icon: Icons.receipt_outlined,        label: 'Receipt'),
    (icon: Icons.percent_outlined,        label: 'Tax & Pricing'),
    (icon: Icons.sync_outlined,           label: 'Sync & Backup'),
    (icon: Icons.lock_outline,            label: 'Security'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        children: [
          // ── Page header ──────────────────────────────────
          _SettingsHeader(),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left tab rail ────────────────────────
                Container(
                  width: 210,
                  decoration: const BoxDecoration(
                    color: AppColors.gray50,
                    border: Border(right: BorderSide(color: AppColors.gray200)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                  child: Column(
                    children: List.generate(_tabs.length, (i) {
                      final t = _tabs[i];
                      return _TabRailItem(
                        icon: t.icon,
                        label: t.label,
                        active: _tab == i,
                        onTap: () => setState(() => _tab = i),
                      );
                    }),
                  ),
                ),

                // ── Right content pane ───────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: _buildTabContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tab) {
      case 0: return const _StoreInfoTab();
      case 1: return const _ReceiptTab();
      case 2: return const _TaxTab();
      case 3: return const _SyncTab();
      case 4: return const _SecurityTab();
      default: return const SizedBox();
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB 0 — STORE INFORMATION
// ─────────────────────────────────────────────────────────────
class _StoreInfoTab extends StatefulWidget {
  const _StoreInfoTab();

  @override
  State<_StoreInfoTab> createState() => _StoreInfoTabState();
}

class _StoreInfoTabState extends State<_StoreInfoTab> {
  final _nameCtrl    = TextEditingController(text: 'Shree Sarees');
  final _phoneCtrl   = TextEditingController(text: '+91 98765 43210');
  final _emailCtrl   = TextEditingController(text: 'contact@shreesarees.com');
  final _gstCtrl     = TextEditingController(text: '22AAAAA0000A1Z5');
  final _addressCtrl = TextEditingController(
      text: '42, Main Market Road\nVaranasi, UP 221001');
  final _cityCtrl    = TextEditingController(text: 'Varanasi');
  final _stateCtrl   = TextEditingController(text: 'Uttar Pradesh');

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _emailCtrl, _gstCtrl,
      _addressCtrl, _cityCtrl, _stateCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Store Details',
            subtitle: 'Your business information shown on receipts and invoices'),
        const SizedBox(height: 20),

        _SettingsRow(children: [
          _SettingsField(label: 'Store Name *', ctrl: _nameCtrl),
          _SettingsField(label: 'Phone Number', ctrl: _phoneCtrl),
        ]),
        const SizedBox(height: 16),
        _SettingsRow(children: [
          _SettingsField(label: 'Email Address', ctrl: _emailCtrl),
          _SettingsField(label: 'GST Number', ctrl: _gstCtrl,
              hint: 'e.g. 22AAAAA0000A1Z5'),
        ]),
        const SizedBox(height: 16),
        _SettingsField(
          label: 'Store Address',
          ctrl: _addressCtrl,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _SettingsRow(children: [
          _SettingsField(label: 'City', ctrl: _cityCtrl),
          _SettingsField(label: 'State', ctrl: _stateCtrl),
        ]),

        const SizedBox(height: 28),
        _Divider(),
        const SizedBox(height: 24),

        _SectionTitle('Logo & Branding',
            subtitle: 'Upload your store logo to appear on printed receipts'),
        const SizedBox(height: 16),
        _LogoUploadBox(),

        const SizedBox(height: 28),
        _SaveButton(onTap: () => _showSaved(context)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB 1 — RECEIPT SETTINGS
// ─────────────────────────────────────────────────────────────
class _ReceiptTab extends StatefulWidget {
  const _ReceiptTab();

  @override
  State<_ReceiptTab> createState() => _ReceiptTabState();
}

class _ReceiptTabState extends State<_ReceiptTab> {
  final _footerCtrl  = TextEditingController(text: 'Thank you for shopping!');
  final _headerCtrl  = TextEditingController(text: 'Shree Sarees');
  bool _showGst      = true;
  bool _showBarcode  = true;
  bool _autoPrint    = false;
  String _paperSize  = 'A4';
  String _copies     = '1';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Receipt Layout',
            subtitle: 'Configure how your receipts look when printed'),
        const SizedBox(height: 20),

        _SettingsRow(children: [
          _DropdownField(
            label: 'Paper Size',
            value: _paperSize,
            items: const ['A4', 'A5', '80mm Thermal', '58mm Thermal'],
            onChanged: (v) => setState(() => _paperSize = v ?? _paperSize),
          ),
          _DropdownField(
            label: 'Default Copies',
            value: _copies,
            items: const ['1', '2', '3'],
            onChanged: (v) => setState(() => _copies = v ?? _copies),
          ),
        ]),
        const SizedBox(height: 16),
        _SettingsField(label: 'Receipt Header Text', ctrl: _headerCtrl),
        const SizedBox(height: 16),
        _SettingsField(
            label: 'Receipt Footer / Thank-you Message',
            ctrl: _footerCtrl,
            maxLines: 3),

        const SizedBox(height: 24),
        _Divider(),
        const SizedBox(height: 20),

        _SectionTitle('Receipt Options', subtitle: 'Toggle what appears on the receipt'),
        const SizedBox(height: 16),

        _ToggleTile(
          title: 'Show GST breakdown',
          subtitle: 'Display individual tax components on the receipt',
          value: _showGst,
          onChanged: (v) => setState(() => _showGst = v),
        ),
        _ToggleTile(
          title: 'Show product barcode',
          subtitle: 'Print item barcodes on each receipt line',
          value: _showBarcode,
          onChanged: (v) => setState(() => _showBarcode = v),
        ),
        _ToggleTile(
          title: 'Auto-print after payment',
          subtitle: 'Automatically send to printer when transaction is confirmed',
          value: _autoPrint,
          onChanged: (v) => setState(() => _autoPrint = v),
        ),

        const SizedBox(height: 28),
        _SaveButton(onTap: () => _showSaved(context)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB 2 — TAX & PRICING
// ─────────────────────────────────────────────────────────────
class _TaxTab extends StatefulWidget {
  const _TaxTab();

  @override
  State<_TaxTab> createState() => _TaxTabState();
}

class _TaxTabState extends State<_TaxTab> {
  bool   _taxEnabled    = true;
  bool   _priceInclTax  = false;
  String _defaultGst    = 'GST 5%';
  String _currency      = '₹ INR';
  final  _cgstCtrl      = TextEditingController(text: '2.5');
  final  _sgstCtrl      = TextEditingController(text: '2.5');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Tax Configuration',
            subtitle: 'Set up GST and tax rules for your products'),
        const SizedBox(height: 20),

        _ToggleTile(
          title: 'Enable Tax / GST',
          subtitle: 'Apply GST to all transactions by default',
          value: _taxEnabled,
          onChanged: (v) => setState(() => _taxEnabled = v),
        ),
        _ToggleTile(
          title: 'Prices inclusive of tax',
          subtitle: 'Show tax-inclusive prices on billing screen',
          value: _priceInclTax,
          onChanged: (v) => setState(() => _priceInclTax = v),
        ),

        const SizedBox(height: 20),

        _SettingsRow(children: [
          _DropdownField(
            label: 'Default GST Rate',
            value: _defaultGst,
            items: const ['GST 5%', 'GST 12%', 'GST 18%', 'GST 28%', 'Tax Free'],
            onChanged: (v) => setState(() => _defaultGst = v ?? _defaultGst),
          ),
          _DropdownField(
            label: 'Currency',
            value: _currency,
            items: const ['₹ INR', '\$ USD', '€ EUR'],
            onChanged: (v) => setState(() => _currency = v ?? _currency),
          ),
        ]),

        const SizedBox(height: 16),

        _SectionTitle('GST Split (CGST + SGST)',
            subtitle: 'Configure how GST is split for invoice display'),
        const SizedBox(height: 12),

        _SettingsRow(children: [
          _SettingsField(label: 'CGST %', ctrl: _cgstCtrl,
              hint: 'e.g. 2.5'),
          _SettingsField(label: 'SGST %', ctrl: _sgstCtrl,
              hint: 'e.g. 2.5'),
        ]),

        const SizedBox(height: 28),
        _SaveButton(onTap: () => _showSaved(context)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB 3 — SYNC & BACKUP
// ─────────────────────────────────────────────────────────────
class _SyncTab extends StatefulWidget {
  const _SyncTab();

  @override
  State<_SyncTab> createState() => _SyncTabState();
}

class _SyncTabState extends State<_SyncTab> {
  bool _autoSync    = true;
  bool _wifiOnly    = true;
  bool _autoBackup  = false;
  String _syncFreq  = 'Every 5 minutes';
  bool _syncing     = false;

  void _triggerSync() async {
    setState(() => _syncing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _syncing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Firebase Sync',
            subtitle: 'Configure how data syncs between devices and the cloud'),
        const SizedBox(height: 20),

        // Sync status card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.teal50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.teal100),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.teal600,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cloud_done_outlined,
                    color: AppColors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Last synced: Today at 11:30 AM',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.teal700)),
                    SizedBox(height: 2),
                    Text('All data is up to date',
                        style: TextStyle(fontSize: 12, color: AppColors.teal600)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _syncing ? null : _triggerSync,
                icon: _syncing
                    ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white))
                    : const Icon(Icons.sync, size: 16),
                label: Text(_syncing ? 'Syncing…' : 'Sync Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal600,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _ToggleTile(
          title: 'Enable Auto Sync',
          subtitle: 'Automatically sync data to Firebase in the background',
          value: _autoSync,
          onChanged: (v) => setState(() => _autoSync = v),
        ),
        _ToggleTile(
          title: 'Sync on Wi-Fi only',
          subtitle: 'Prevent syncing over metered mobile data connections',
          value: _wifiOnly,
          onChanged: (v) => setState(() => _wifiOnly = v),
        ),

        const SizedBox(height: 16),

        _DropdownField(
          label: 'Sync Frequency',
          value: _syncFreq,
          items: const [
            'Every minute',
            'Every 5 minutes',
            'Every 15 minutes',
            'Every hour',
            'Manual only',
          ],
          onChanged: (v) => setState(() => _syncFreq = v ?? _syncFreq),
        ),

        const SizedBox(height: 24),
        _Divider(),
        const SizedBox(height: 20),

        _SectionTitle('Local Backup',
            subtitle: 'Export a local SQLite backup of all offline data'),
        const SizedBox(height: 16),

        _ToggleTile(
          title: 'Auto Backup on Close',
          subtitle: 'Save a local backup every time the app is closed',
          value: _autoBackup,
          onChanged: (v) => setState(() => _autoBackup = v),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined, size: 16),
              label: const Text('Export Backup Now'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gray700,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                side: const BorderSide(color: AppColors.gray300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_outlined, size: 16),
              label: const Text('Restore from Backup'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gray700,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                side: const BorderSide(color: AppColors.gray300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),
        _SaveButton(onTap: () => _showSaved(context)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB 4 — SECURITY
// ─────────────────────────────────────────────────────────────
class _SecurityTab extends StatefulWidget {
  const _SecurityTab();

  @override
  State<_SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<_SecurityTab> {
  final _currentPinCtrl = TextEditingController();
  final _newPinCtrl     = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  bool _pinLock         = true;
  bool _autoLock        = true;
  bool _activityLog     = true;
  String _lockTimeout   = '5 minutes';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Access & PIN',
            subtitle: 'Protect your POS terminal with a PIN lock'),
        const SizedBox(height: 20),

        _ToggleTile(
          title: 'Enable PIN Lock',
          subtitle: 'Require a PIN to access the POS system on startup',
          value: _pinLock,
          onChanged: (v) => setState(() => _pinLock = v),
        ),

        const SizedBox(height: 20),

        _SectionTitle('Change PIN', subtitle: 'Update your terminal access PIN'),
        const SizedBox(height: 16),

        _SettingsRow(children: [
          _SettingsField(
              label: 'Current PIN',
              ctrl: _currentPinCtrl,
              obscure: true,
              hint: '••••••'),
          _SettingsField(
              label: 'New PIN',
              ctrl: _newPinCtrl,
              obscure: true,
              hint: '••••••'),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          width: 280,
          child: _SettingsField(
              label: 'Confirm New PIN',
              ctrl: _confirmPinCtrl,
              obscure: true,
              hint: '••••••'),
        ),

        const SizedBox(height: 24),
        _Divider(),
        const SizedBox(height: 20),

        _SectionTitle('Auto-lock & Activity',
            subtitle: 'Configure idle timeout and audit logging'),
        const SizedBox(height: 16),

        _ToggleTile(
          title: 'Auto-lock on Idle',
          subtitle: 'Lock the terminal automatically after a period of inactivity',
          value: _autoLock,
          onChanged: (v) => setState(() => _autoLock = v),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: 280,
          child: _DropdownField(
            label: 'Lock Timeout',
            value: _lockTimeout,
            items: const ['1 minute', '5 minutes', '10 minutes', '30 minutes', 'Never'],
            onChanged: (v) => setState(() => _lockTimeout = v ?? _lockTimeout),
          ),
        ),

        const SizedBox(height: 16),
        _ToggleTile(
          title: 'Activity Log',
          subtitle: 'Keep a log of all login and billing actions for audit',
          value: _activityLog,
          onChanged: (v) => setState(() => _activityLog = v),
        ),

        const SizedBox(height: 28),
        _SaveButton(onTap: () => _showSaved(context)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          const Icon(Icons.settings_outlined, color: AppColors.teal600, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTextStyles.h2),
              const SizedBox(height: 1),
              Text('Configure your POS system preferences',
                  style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabRailItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabRailItem(
      {required this.icon, required this.label, required this.active, required this.onTap});

  @override
  State<_TabRailItem> createState() => _TabRailItemState();
}

class _TabRailItemState extends State<_TabRailItem> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    Color bg = widget.active
        ? AppColors.teal600
        : _hov
        ? AppColors.gray200
        : Colors.transparent;
    Color fg = widget.active ? AppColors.white : AppColors.gray600;

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: fg),
              const SizedBox(width: 10),
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight:
                      widget.active ? FontWeight.w600 : FontWeight.w500,
                      color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionTitle(this.title, {this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final List<Widget> children;
  const _SettingsRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .expand((w) => [Expanded(child: w), const SizedBox(width: 16)])
          .toList()
        ..removeLast(),
    );
  }
}

class _SettingsField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String? hint;
  final int maxLines;
  final bool obscure;

  const _SettingsField({
    required this.label,
    required this.ctrl,
    this.hint,
    this.maxLines = 1,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.gray50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.teal600, width: 2),
            ),
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
          ),
          style: const TextStyle(fontSize: 14, color: AppColors.gray800),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700)),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gray300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.gray800))))
                  .toList(),
              onChanged: onChanged,
              icon: const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: AppColors.gray500),
              style: AppTextStyles.body,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile(
      {required this.title,
        required this.subtitle,
        required this.value,
        required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray800)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.teal600,
          ),
        ],
      ),
    );
  }
}

class _LogoUploadBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.gray300,
            style: BorderStyle.solid),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(10),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file_outlined,
                size: 32, color: AppColors.gray400),
            SizedBox(height: 8),
            Text('Click to upload store logo',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray500)),
            SizedBox(height: 4),
            Text('PNG or JPG, max 2MB',
                style: TextStyle(fontSize: 12, color: AppColors.gray400)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: AppColors.gray200);
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Save Changes'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal600,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gray600,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            side: const BorderSide(color: AppColors.gray300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          child: const Text('Reset to Defaults'),
        ),
      ],
    );
  }
}

// Helper function used in tab state classes
void _showSaved(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle_outline, color: AppColors.white, size: 18),
        SizedBox(width: 8),
        Text('Settings saved successfully!'),
      ]),
      backgroundColor: AppColors.teal600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
    ),
  );
}
