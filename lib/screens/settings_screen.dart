import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/theme_provider.dart';
import '../core/app_colors_ext.dart';

/// ─────────────────────────────────────────────────────────────
///  SETTINGS SCREEN  –  lib/screens/settings_screen.dart
///  7 tabs matching Figma exactly:
///    Shop Settings | Billing Settings | Inventory Settings |
///    User & Security | Backup & Sync | Printer Settings |
///    System Settings
/// ─────────────────────────────────────────────────────────────

class _Tab {
  final String key;
  final String label;
  final IconData icon;
  const _Tab(this.key, this.label, this.icon);
}

const _tabs = [
  _Tab('shop',      'Shop Settings',      Icons.storefront_outlined),
  _Tab('billing',   'Billing Settings',   Icons.receipt_long_outlined),
  _Tab('inventory', 'Inventory Settings', Icons.inventory_2_outlined),
  _Tab('users',     'User & Security',    Icons.person_outline),
  _Tab('sync',      'Backup & Sync',      Icons.sync_outlined),
  _Tab('printer',   'Printer Settings',   Icons.print_outlined),
  _Tab('system',    'System Settings',    Icons.settings_outlined),
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _active = 'shop';

  Widget _content() {
    switch (_active) {
      case 'shop':      return const _ShopTab();
      case 'billing':   return const _BillingTab();
      case 'inventory': return const _InventoryTab();
      case 'users':     return const _UsersTab();
      case 'sync':      return const _SyncTab();
      case 'printer':   return const _PrinterTab();
      case 'system':    return const _SystemTab();
      default:          return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left rail ──────────────────────────────────────
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: c.cardBg,
              border: Border(right: BorderSide(color: c.border)),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Settings',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                              color: c.textPrimary)),
                      const SizedBox(height: 2),
                      Text('System Preferences',
                          style: TextStyle(fontSize: 12, color: c.textMuted)),
                    ],
                  ),
                ),
                Divider(height: 1, color: c.border),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: _tabs.map((t) => _RailTile(
                      tab: t,
                      active: _active == t.key,
                      onTap: () => setState(() => _active = t.key),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── Right content ───────────────────────────────────
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
                child: _content(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  TAB CONTENTS
// ═════════════════════════════════════════════════════════════

// ── 1. SHOP SETTINGS ─────────────────────────────────────────
class _ShopTab extends StatefulWidget {
  const _ShopTab();
  @override State<_ShopTab> createState() => _ShopTabState();
}
class _ShopTabState extends State<_ShopTab> {
  final _name    = TextEditingController(text: 'SHREE SAREES');
  final _owner   = TextEditingController(text: 'Admin User');
  final _phone   = TextEditingController(text: '+91 98765432');
  final _address = TextEditingController(
      text: '123 Silk Street, Gandhi Nagar,\nChennai, Tamil Nadu - 600020');
  final _gst     = TextEditingController(text: '33AAAAA0000');

  @override void dispose() {
    for (final c in [_name,_owner,_phone,_address,_gst]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header('Shop Details', 'Manage your primary store information.'),
      const SizedBox(height: 24),

      _Field('Shop Name', _name),
      const SizedBox(height: 16),
      _Row2(
        _Field('Owner Name',   _owner),
        _Field('Phone Number', _phone),
      ),
      const SizedBox(height: 16),
      _Field('Complete Address', _address, lines: 3),
      const SizedBox(height: 16),
      _Field('GST Number', _gst),
      const SizedBox(height: 28),

      _SecDiv('Shop Logo'),
      const SizedBox(height: 16),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray200),
          ),
          child: const Icon(Icons.storefront_outlined, size: 32, color: AppColors.gray400),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_outlined, size: 16),
            label: const Text('Upload New Logo'),
            style: _outlineBtn(),
          ),
          const SizedBox(height: 6),
          const Text('Recommended size: 256×256px.\nFormats: PNG, JPG.',
              style: TextStyle(fontSize: 11, color: AppColors.gray400)),
        ]),
      ]),

      const SizedBox(height: 32),
      _SaveBtn(context),
    ]);
  }
}

// ── 2. BILLING SETTINGS ──────────────────────────────────────
class _BillingTab extends StatefulWidget {
  const _BillingTab();
  @override State<_BillingTab> createState() => _BillingTabState();
}
class _BillingTabState extends State<_BillingTab> {
  final _tax   = TextEditingController(text: '5');
  String _curr = '₹ (INR) - Indian Rupee';
  bool _disc   = true;
  bool _round  = true;
  String _inv  = 'thermal';

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header('Billing & Invoicing', 'Configure tax, discounts, and invoice formats.'),
      const SizedBox(height: 24),

      _Row2(
        // Tax with % suffix
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Lbl('Default Tax (GST %)'),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _TF(ctrl: _tax, hint: '5', keyboard: TextInputType.number)),
            Container(
              height: 44, width: 38,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                border: Border.all(color: AppColors.gray300),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
              ),
              child: const Center(child: Text('%',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.gray500))),
            ),
          ]),
        ]),
        _DDField('Currency', _curr,
            ['₹ (INR) - Indian Rupee', '\$ (USD) - US Dollar', '€ (EUR) - Euro'],
                (v) => setState(() => _curr = v ?? _curr)),
      ),
      const SizedBox(height: 16),

      Row(children: [
        Expanded(child: _TogCard('Enable Discount Option',
            'Allow cashiers to add manual discounts on bills',
            _disc, (v) => setState(() => _disc = v))),
        const SizedBox(width: 16),
        Expanded(child: _TogCard('Auto Round-Off',
            'Round off final bill amount to nearest rupee',
            _round, (v) => setState(() => _round = v))),
      ]),
      const SizedBox(height: 24),

      _Lbl('Default Invoice Type'),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _RadioCard('Thermal Receipt',
            'Standard 3-inch roll paper format',
            _inv == 'thermal', () => setState(() => _inv = 'thermal'))),
        const SizedBox(width: 16),
        Expanded(child: _RadioCard('A4 Standard',
            'Full page invoice for B2B or large orders',
            _inv == 'a4', () => setState(() => _inv = 'a4'))),
      ]),

      const SizedBox(height: 32),
      _SaveBtn(context),
    ]);
  }
}

// ── 3. INVENTORY SETTINGS ────────────────────────────────────
class _InventoryTab extends StatefulWidget {
  const _InventoryTab();
  @override State<_InventoryTab> createState() => _InventoryTabState();
}
class _InventoryTabState extends State<_InventoryTab> {
  bool _track = true;
  bool _auto  = true;
  final _qty  = TextEditingController(text: '10');
  String _unit = 'Pieces (pcs)';

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header('Inventory Management', 'Set alerts and automation rules for stock.'),
      const SizedBox(height: 24),

      _TogCard('Enable Stock Tracking',
          'Prevent billing if item is out of stock',
          _track, (v) => setState(() => _track = v)),
      const SizedBox(height: 12),
      _TogCard('Auto Generate Barcodes (SKU)',
          'Automatically create standard 8-digit barcodes for new products',
          _auto, (v) => setState(() => _auto = v)),
      const SizedBox(height: 20),

      _Row2(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Lbl('Low Stock Alert Threshold'),
          const SizedBox(height: 6),
          _TF(ctrl: _qty, hint: '10', keyboard: TextInputType.number),
          const SizedBox(height: 4),
          const Text('Show warning when stock drops below this number',
              style: TextStyle(fontSize: 11, color: AppColors.gray400)),
        ]),
        _DDField('Default Unit Type', _unit,
            ['Pieces (pcs)','Meters (m)','Kilograms (kg)','Sets'],
                (v) => setState(() => _unit = v ?? _unit)),
      ),

      const SizedBox(height: 32),
      _SaveBtn(context),
    ]);
  }
}

// ── 4. USER & SECURITY ───────────────────────────────────────
class _UsersTab extends StatefulWidget {
  const _UsersTab();
  @override State<_UsersTab> createState() => _UsersTabState();
}
class _UsersTabState extends State<_UsersTab> {
  final _users = [
    ('Admin (Owner)', 'Administrator', true),
    ('Rahul Sharma',  'Cashier',       true),
    ('Priya Singh',   'Cashier',       false),
  ];
  final _cur = TextEditingController();
  final _new = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _Header('User & Roles', 'Manage cashier accounts and permissions.')),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_add_outlined, size: 16),
          label: const Text('Add User'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal600,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
      const SizedBox(height: 20),

      // Users table
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray200),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            decoration: const BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: const Row(children: [
              Expanded(flex: 3, child: _TblH('NAME')),
              Expanded(flex: 2, child: _TblH('ROLE')),
              SizedBox(width: 100, child: _TblH('STATUS', center: true)),
              SizedBox(width: 80,  child: _TblH('ACTIONS', center: true)),
            ]),
          ),
          // Rows
          ..._users.asMap().entries.map((e) {
            final u = e.value;
            final last = e.key == _users.length - 1;
            return Container(
              decoration: BoxDecoration(
                  border: last ? null : const Border(
                      bottom: BorderSide(color: AppColors.gray100))),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(children: [
                Expanded(flex: 3,
                    child: Text(u.$1,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.gray800))),
                Expanded(flex: 2,
                    child: Text(u.$2,
                        style: const TextStyle(fontSize: 14, color: AppColors.gray500))),
                SizedBox(width: 100, child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: u.$3 ? AppColors.green100 : AppColors.gray100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(u.$3 ? 'Active' : 'Inactive',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            color: u.$3 ? AppColors.green700 : AppColors.gray500)),
                  ),
                )),
                SizedBox(width: 80, child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _IBtn(Icons.edit_outlined,   () {}),
                    const SizedBox(width: 4),
                    _IBtn(Icons.delete_outline,  () {}),
                  ],
                )),
              ]),
            );
          }),
        ]),
      ),

      const SizedBox(height: 28),
      _SecDiv('Change Admin Password'),
      const SizedBox(height: 16),

      _Field('Current Password', _cur, obscure: true),
      const SizedBox(height: 14),
      _Field('New Password', _new, obscure: true),
      const SizedBox(height: 20),

      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.slate900,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        child: const Text('Update Password'),
      ),
    ]);
  }
}

// ── 5. BACKUP & SYNC ─────────────────────────────────────────
class _SyncTab extends StatefulWidget {
  const _SyncTab();
  @override State<_SyncTab> createState() => _SyncTabState();
}
class _SyncTabState extends State<_SyncTab> {
  bool _auto   = true;
  bool _wifi   = true;
  bool _backup = false;
  String _freq = 'Every 5 minutes';
  bool _busy   = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header('Backup & Sync', 'Manage cloud sync and local data backups.'),
      const SizedBox(height: 20),

      // Status card
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.teal50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.teal100),
        ),
        child: Row(children: [
          Container(width: 44, height: 44,
              decoration: BoxDecoration(
                  color: AppColors.teal600, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.cloud_done_outlined, color: AppColors.white, size: 22)),
          const SizedBox(width: 14),
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last synced: Today at 11:30 AM',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
                      color: AppColors.teal700)),
              SizedBox(height: 2),
              Text('All data is up to date',
                  style: TextStyle(fontSize: 12, color: AppColors.teal600)),
            ],
          )),
          ElevatedButton.icon(
            onPressed: _busy ? null : () async {
              setState(() => _busy = true);
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) setState(() => _busy = false);
            },
            icon: _busy
                ? const SizedBox(width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2,
                    color: AppColors.white))
                : const Icon(Icons.sync, size: 16),
            label: Text(_busy ? 'Syncing…' : 'Sync Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal600,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 16),

      _TogCard('Auto Sync',
          'Automatically sync data to Firebase in the background',
          _auto, (v) => setState(() => _auto = v)),
      const SizedBox(height: 12),
      _TogCard('Sync on Wi-Fi Only',
          'Prevent syncing over metered connections',
          _wifi, (v) => setState(() => _wifi = v)),
      const SizedBox(height: 16),

      SizedBox(width: 320,
          child: _DDField('Sync Frequency', _freq,
              ['Every minute','Every 5 minutes','Every 15 minutes',
                'Every hour','Manual only'],
                  (v) => setState(() => _freq = v ?? _freq))),

      const SizedBox(height: 24),
      _SecDiv('Local Backup'),
      const SizedBox(height: 14),

      _TogCard('Auto Backup on Close',
          'Save a local backup every time the app is closed',
          _backup, (v) => setState(() => _backup = v)),
      const SizedBox(height: 16),

      Row(children: [
        OutlinedButton.icon(onPressed: () {},
            icon: const Icon(Icons.download_outlined, size: 16),
            label: const Text('Export Backup'),
            style: _outlineBtn()),
        const SizedBox(width: 12),
        OutlinedButton.icon(onPressed: () {},
            icon: const Icon(Icons.upload_outlined, size: 16),
            label: const Text('Restore from Backup'),
            style: _outlineBtn()),
      ]),

      const SizedBox(height: 32),
      _SaveBtn(context),
    ]);
  }
}

// ── 6. PRINTER SETTINGS ──────────────────────────────────────
class _PrinterTab extends StatefulWidget {
  const _PrinterTab();
  @override State<_PrinterTab> createState() => _PrinterTabState();
}
class _PrinterTabState extends State<_PrinterTab> {
  String _printer = 'EPSON TM-T82III Receipt (USB)';
  String _paper   = '80mm (Standard Receipt)';
  bool  _auto     = true;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header('Hardware & Printers', 'Connect thermal receipt printers and cash drawers.'),
      const SizedBox(height: 24),

      _DDField('Select Active Printer', _printer,
          ['EPSON TM-T82III Receipt (USB)','Generic Thermal Printer',
            'Star TSP100III (LAN)','No Printer'],
              (v) => setState(() => _printer = v ?? _printer)),
      const SizedBox(height: 16),

      _DDField('Paper Roll Size', _paper,
          ['80mm (Standard Receipt)','58mm (Small Roll)','A4','A5'],
              (v) => setState(() => _paper = v ?? _paper)),
      const SizedBox(height: 20),

      _TogCard('Auto Print on Checkout',
          'Instantly print receipt after payment confirmation',
          _auto, (v) => setState(() => _auto = v)),
      const SizedBox(height: 20),

      ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.print_outlined, size: 16),
        label: const Text('Print Test Page'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.slate900,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      const SizedBox(height: 32),
      _SaveBtn(context),
    ]);
  }
}

// ── 7. SYSTEM SETTINGS ───────────────────────────────────────
class _SystemTab extends StatefulWidget {
  const _SystemTab();
  @override State<_SystemTab> createState() => _SystemTabState();
}
class _SystemTabState extends State<_SystemTab> {
  String _lang   = 'English';
  String _date   = 'DD/MM/YYYY';
  String _time   = '12-hour (AM/PM)';

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder re-renders the cards whenever theme changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Header('System Preferences', 'Customize the interface and localization settings.'),
          const SizedBox(height: 24),

          _Lbl('Interface Theme'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _ThemeCard('Light Mode', Icons.wb_sunny_outlined,
                const Color(0xFFF59E0B), null,
                !isDark,                                                    // selected when light
                    () => appThemeNotifier.value = ThemeMode.light)),          // ← writes to global
            const SizedBox(width: 16),
            Expanded(child: _ThemeCard('Dark Mode', Icons.dark_mode_outlined,
                AppColors.white, AppColors.slate900,
                isDark,                                                     // selected when dark
                    () => appThemeNotifier.value = ThemeMode.dark)),           // ← writes to global
          ]),
          const SizedBox(height: 24),

          _Row2(
            _DDField('Language', _lang,
                ['English','Hindi','Tamil','Telugu'],
                    (v) => setState(() => _lang = v ?? _lang)),
            _DDField('Date Format', _date,
                ['DD/MM/YYYY','MM/DD/YYYY','YYYY-MM-DD'],
                    (v) => setState(() => _date = v ?? _date)),
          ),
          const SizedBox(height: 16),

          SizedBox(width: 320,
              child: _DDField('Time Format', _time,
                  ['12-hour (AM/PM)','24-hour'],
                      (v) => setState(() => _time = v ?? _time))),

          const SizedBox(height: 32),
          _SaveBtn(context),
        ]); // end Column
      },  // end builder
    );   // end ValueListenableBuilder
  }
}

// ═════════════════════════════════════════════════════════════
//  SHARED COMPONENTS
// ═════════════════════════════════════════════════════════════

// Left rail tile
class _RailTile extends StatefulWidget {
  final _Tab tab;
  final bool active;
  final VoidCallback onTap;
  const _RailTile({required this.tab, required this.active, required this.onTap});
  @override State<_RailTile> createState() => _RailTileState();
}
class _RailTileState extends State<_RailTile> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    final a = widget.active;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: a ? AppColors.teal600 : (_hov ? context.colors.borderLight : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(widget.tab.icon, size: 17,
                color: a ? AppColors.white : AppColors.gray500),
            const SizedBox(width: 10),
            Text(widget.tab.label,
                style: TextStyle(fontSize: 13,
                    fontWeight: a ? FontWeight.w600 : FontWeight.w500,
                    color: a ? AppColors.white : AppColors.gray600)),
          ]),
        ),
      ),
    );
  }
}

// Content header
class _Header extends StatelessWidget {
  final String title;
  final String sub;
  const _Header(this.title, this.sub);
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
            color: c.textPrimary)),
        const SizedBox(height: 4),
        Text(sub, style: TextStyle(fontSize: 13, color: c.textMuted)),
      ],
    );
  }
}

// Labelled text field
class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final int lines;
  final bool obscure;
  const _Field(this.label, this.ctrl, {this.lines = 1, this.obscure = false});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Lbl(label),
      const SizedBox(height: 6),
      _TF(ctrl: ctrl, lines: lines, obscure: obscure),
    ],
  );
}

// Two-column row
class _Row2 extends StatelessWidget {
  final Widget a, b;
  const _Row2(this.a, this.b);
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [Expanded(child: a), const SizedBox(width: 16), Expanded(child: b)],
  );
}

// Dropdown field with label
Widget _DDField(String label, String value, List<String> items,
    ValueChanged<String?> onChanged) {
  return Builder(builder: (context) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Lbl(label),
      const SizedBox(height: 6),
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: c.inputFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: c.cardBg,
            items: items.map((e) => DropdownMenuItem(value: e,
                child: Text(e, style: TextStyle(fontSize: 14, color: c.textPrimary),
                    overflow: TextOverflow.ellipsis))).toList(),
            onChanged: onChanged,
            icon: Icon(Icons.keyboard_arrow_down, size: 18, color: c.textMuted),
            style: TextStyle(fontSize: 14, color: c.textPrimary),
          ),
        ),
      ),
    ]);
  });
}

// Toggle card — uses Builder to get context for adaptive colors
Widget _TogCard(String title, String sub, bool val, ValueChanged<bool> onChange) {
  return Builder(builder: (context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
              color: c.textPrimary)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 12, color: c.textMuted)),
        ])),
        Switch(value: val, onChanged: onChange, activeColor: AppColors.teal600),
      ]),
    );
  });
}

// Radio card (invoice type)
Widget _RadioCard(String title, String sub, bool sel, VoidCallback onTap) {
  return Builder(builder: (context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sel ? AppColors.teal50 : c.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? AppColors.teal600 : c.border,
              width: sel ? 2 : 1),
        ),
        child: Row(children: [
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: sel ? AppColors.teal600 : AppColors.gray300,
                  width: sel ? 5 : 1.5),
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: sel ? AppColors.teal700 : c.textPrimary)),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 12,
                color: sel ? AppColors.teal600 : c.textMuted)),
          ])),
        ]),
      ),
    );  // Builder
  });
}

// Theme card
Widget _ThemeCard(String label, IconData icon, Color iconColor, Color? iconBg,
    bool sel, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: sel ? AppColors.teal50 : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: sel ? AppColors.teal600 : AppColors.gray200,
            width: sel ? 2 : 1),
      ),
      child: Column(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: iconBg ?? const Color(0xFFFEF3C7),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: iconColor),
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
            color: sel ? AppColors.teal700 : AppColors.gray700)),
      ]),
    ),
  );
}

// Section divider
class _SecDiv extends StatelessWidget {
  final String label;
  const _SecDiv(this.label);
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
        color: AppColors.gray800)),
    const SizedBox(width: 12),
    const Expanded(child: Divider(color: AppColors.gray200)),
  ]);
}

// Table header
class _TblH extends StatelessWidget {
  final String text;
  final bool center;
  const _TblH(this.text, {this.center = false});
  @override
  Widget build(BuildContext context) => Text(text,
      textAlign: center ? TextAlign.center : TextAlign.left,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppColors.gray500, letterSpacing: 0.5));
}

// Icon button
class _IBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IBtn(this.icon, this.onTap);
  @override State<_IBtn> createState() => _IBtnState();
}
class _IBtnState extends State<_IBtn> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hov = true),
    onExit:  (_) => setState(() => _hov = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: _hov ? AppColors.gray100 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(widget.icon, size: 16,
            color: _hov ? AppColors.gray600 : AppColors.gray400),
      ),
    ),
  );
}

// Save button
Widget _SaveBtn(BuildContext context) => ElevatedButton(
  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: const Row(children: [
      Icon(Icons.check_circle_outline, color: AppColors.white, size: 18),
      SizedBox(width: 8),
      Text('Settings saved successfully!'),
    ]),
    backgroundColor: AppColors.teal600,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: const Duration(seconds: 2),
  )),
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.teal600,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 0,
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
  ),
  child: const Text('Save Changes'),
);

// Field label
class _Lbl extends StatelessWidget {
  final String t;
  const _Lbl(this.t);
  @override
  Widget build(BuildContext context) => Text(t,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: context.colors.textSecond));
}

// Text field
Widget _TF({
  required TextEditingController ctrl,
  String? hint,
  int lines = 1,
  bool obscure = false,
  TextInputType? keyboard,
}) => Builder(builder: (context) {
  final c = context.colors;
  return TextField(
    controller: ctrl,
    maxLines: lines,
    obscureText: obscure,
    keyboardType: keyboard,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: c.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.teal600, width: 2)),
      hintStyle: TextStyle(fontSize: 13, color: c.textMuted),
    ),
    style: TextStyle(fontSize: 14, color: c.textPrimary),
  );
});

ButtonStyle _outlineBtn() => OutlinedButton.styleFrom(
  foregroundColor: AppColors.gray700,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  side: const BorderSide(color: AppColors.gray300),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
);