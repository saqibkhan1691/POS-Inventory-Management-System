import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme.dart';
import '../core/theme_provider.dart';
import '../core/app_colors_ext.dart';
import '../models/settings_model.dart';
import '../repositories/settings_repository.dart';

/// ─────────────────────────────────────────────────────────────
///  SETTINGS SCREEN  –  lib/screens/settings_screen.dart
///  Per-user settings stored in SQLite.
///  Pass userId from login — each user sees only their settings.
/// ─────────────────────────────────────────────────────────────

class _Tab {
  final String key, label;
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
  // Pass the logged-in userId — defaults to 'default' until real auth is added
  final String userId;
  const SettingsScreen({super.key, this.userId = 'default'});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _repo = SettingsRepository();
  String _active = 'shop';
  SettingsModel? _settings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    final s = await _repo.load(widget.userId);
    setState(() { _settings = s; _loading = false; });
  }

  Future<void> _saveSettings(SettingsModel updated) async {
    await _repo.save(updated);
    setState(() => _settings = updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_outline, color: AppColors.white, size: 18),
          SizedBox(width: 8),
          Text('Settings saved!'),
        ]),
        backgroundColor: AppColors.teal600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Widget _content() {
    if (_loading || _settings == null) {
      return const Center(child: CircularProgressIndicator());
    }
    switch (_active) {
      case 'shop':      return _ShopTab(     settings: _settings!, onSave: _saveSettings);
      case 'billing':   return _BillingTab(  settings: _settings!, onSave: _saveSettings);
      case 'inventory': return _InventoryTab(settings: _settings!, onSave: _saveSettings);
      case 'users':     return const _UsersTab();
      case 'sync':      return _SyncTab(     settings: _settings!, onSave: _saveSettings);
      case 'printer':   return _PrinterTab(  settings: _settings!, onSave: _saveSettings);
      case 'system':    return _SystemTab(   settings: _settings!, onSave: _saveSettings);
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
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Left rail
        Container(
          width: 220,
          decoration: BoxDecoration(
            color: c.cardBg,
            border: Border(right: BorderSide(color: c.border)),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Settings', style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w700, color: c.textPrimary)),
                const SizedBox(height: 2),
                Text('System Preferences',
                    style: TextStyle(fontSize: 12, color: c.textMuted)),
              ]),
            ),
            Divider(height: 1, color: c.border),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(children: _tabs.map((t) => _RailTile(
                tab: t, active: _active == t.key,
                onTap: () => setState(() => _active = t.key),
              )).toList()),
            ),
          ]),
        ),
        // Right content
        Expanded(child: ClipRRect(
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
            child: _content(),
          ),
        )),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  TAB 1 — SHOP SETTINGS
// ═════════════════════════════════════════════════════════════
class _ShopTab extends StatefulWidget {
  final SettingsModel settings;
  final Future<void> Function(SettingsModel) onSave;
  const _ShopTab({required this.settings, required this.onSave});
  @override State<_ShopTab> createState() => _ShopTabState();
}
class _ShopTabState extends State<_ShopTab> {
  late final _name    = TextEditingController(text: widget.settings.shopName);
  late final _owner   = TextEditingController(text: widget.settings.ownerName);
  late final _phone   = TextEditingController(text: widget.settings.phone);
  late final _address = TextEditingController(text: widget.settings.address);
  late final _gst     = TextEditingController(text: widget.settings.gstNumber);
  bool _saving = false;

  @override void dispose() {
    for (final c in [_name,_owner,_phone,_address,_gst]) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSave(widget.settings.copyWith(
      shopName:  _name.text.trim(),
      ownerName: _owner.text.trim(),
      phone:     _phone.text.trim(),
      address:   _address.text.trim(),
      gstNumber: _gst.text.trim(),
      updatedAt: DateTime.now(),
    ));
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header('Shop Details', 'Manage your primary store information.'),
      const SizedBox(height: 24),
      _Field('Shop Name', _name),
      const SizedBox(height: 16),
      _Row2(_Field('Owner Name', _owner), _Field('Phone Number', _phone)),
      const SizedBox(height: 16),
      _Field('Complete Address', _address, lines: 3),
      const SizedBox(height: 16),
      _Field('GST Number', _gst),
      const SizedBox(height: 32),
      _SaveBtn(_save, _saving),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════
//  TAB 2 — BILLING SETTINGS
// ═════════════════════════════════════════════════════════════
class _BillingTab extends StatefulWidget {
  final SettingsModel settings;
  final Future<void> Function(SettingsModel) onSave;
  const _BillingTab({required this.settings, required this.onSave});
  @override State<_BillingTab> createState() => _BillingTabState();
}
class _BillingTabState extends State<_BillingTab> {
  late final _tax = TextEditingController(
      text: widget.settings.taxPercent.toStringAsFixed(0));
  late String _curr = widget.settings.currency;
  late bool   _disc = widget.settings.discountEnabled;
  late bool   _round= widget.settings.autoRoundOff;
  late String _inv  = widget.settings.invoiceType;
  bool _saving = false;

  @override void dispose() { _tax.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSave(widget.settings.copyWith(
      taxPercent:      double.tryParse(_tax.text) ?? widget.settings.taxPercent,
      currency:        _curr,
      discountEnabled: _disc,
      autoRoundOff:    _round,
      invoiceType:     _inv,
      updatedAt:       DateTime.now(),
    ));
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header('Billing & Invoicing', 'Configure tax, discounts, and invoice formats.'),
      const SizedBox(height: 24),
      _Row2(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Lbl('Default Tax (GST %)'),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _TF(ctrl: _tax, hint: '5',
                keyboard: TextInputType.number)),
            Builder(builder: (ctx) => Container(
              height: 44, width: 38,
              decoration: BoxDecoration(
                color: ctx.colors.inputFill,
                border: Border.all(color: ctx.colors.border),
                borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(8)),
              ),
              child: Center(child: Text('%', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: ctx.colors.textMuted))),
            )),
          ]),
        ]),
        _DDField('Currency', _curr,
            ['₹ (INR) - Indian Rupee','\$ (USD)',  '€ (EUR)'],
                (v) => setState(() => _curr = v ?? _curr)),
      ),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _TogCard('Enable Discount Option',
            'Allow cashiers to add manual discounts',
            _disc, (v) => setState(() => _disc = v))),
        const SizedBox(width: 16),
        Expanded(child: _TogCard('Auto Round-Off',
            'Round off final bill to nearest rupee',
            _round, (v) => setState(() => _round = v))),
      ]),
      const SizedBox(height: 24),
      _Lbl('Default Invoice Type'),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _RadioCard('Thermal Receipt',
            'Standard 3-inch roll paper',
            _inv == 'thermal', () => setState(() => _inv = 'thermal'))),
        const SizedBox(width: 16),
        Expanded(child: _RadioCard('A4 Standard',
            'Full page invoice for large orders',
            _inv == 'a4', () => setState(() => _inv = 'a4'))),
      ]),
      const SizedBox(height: 32),
      _SaveBtn(_save, _saving),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════
//  TAB 3 — INVENTORY SETTINGS
// ═════════════════════════════════════════════════════════════
class _InventoryTab extends StatefulWidget {
  final SettingsModel settings;
  final Future<void> Function(SettingsModel) onSave;
  const _InventoryTab({required this.settings, required this.onSave});
  @override State<_InventoryTab> createState() => _InventoryTabState();
}
class _InventoryTabState extends State<_InventoryTab> {
  late bool   _track = widget.settings.trackStock;
  late bool   _auto  = widget.settings.autoBarcode;
  late final _qty = TextEditingController(
      text: widget.settings.lowStockAlert.toString());
  late String _unit  = widget.settings.defaultUnit;
  bool _saving = false;

  @override void dispose() { _qty.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSave(widget.settings.copyWith(
      trackStock:    _track,
      autoBarcode:   _auto,
      lowStockAlert: int.tryParse(_qty.text) ?? widget.settings.lowStockAlert,
      defaultUnit:   _unit,
      updatedAt:     DateTime.now(),
    ));
    if (mounted) setState(() => _saving = false);
  }

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
          'Automatically create 8-digit barcodes for new products',
          _auto, (v) => setState(() => _auto = v)),
      const SizedBox(height: 20),
      _Row2(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Lbl('Low Stock Alert Threshold'),
          const SizedBox(height: 6),
          _TF(ctrl: _qty, hint: '10', keyboard: TextInputType.number),
          const SizedBox(height: 4),
          Builder(builder: (ctx) => Text(
            'Show warning when stock drops below this number',
            style: TextStyle(fontSize: 11, color: ctx.colors.textMuted),
          )),
        ]),
        _DDField('Default Unit Type', _unit,
            ['Pieces (pcs)','Meters (m)','Kilograms (kg)','Sets'],
                (v) => setState(() => _unit = v ?? _unit)),
      ),
      const SizedBox(height: 32),
      _SaveBtn(_save, _saving),
    ]);
  }
}

/// ─────────────────────────────────────────────────────────────
///  USER & SECURITY TAB
///  Replace _UsersTab class in settings_screen.dart with this
/// ─────────────────────────────────────────────────────────────
class _UsersTab extends StatefulWidget {
  const _UsersTab();
  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl     = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _changingPass   = false;
  bool _sendingReset   = false;
  String? _passError;
  String? _passSuccess;

  Map<String, dynamic>? _userData;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    setState(() {
      _userData    = doc.data();
      _loadingUser = false;
    });
  }

  Future<void> _changePassword() async {
    setState(() { _passError = null; _passSuccess = null; });

    if (_currentPassCtrl.text.isEmpty ||
        _newPassCtrl.text.isEmpty ||
        _confirmPassCtrl.text.isEmpty) {
      setState(() => _passError = 'Please fill all password fields.');
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      setState(() => _passError = 'New password must be at least 6 characters.');
      return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      setState(() => _passError = 'New passwords do not match.');
      return;
    }
    if (_newPassCtrl.text == _currentPassCtrl.text) {
      setState(() => _passError = 'New password cannot be same as current password.');
      return;
    }

    setState(() => _changingPass = true);
    try {
      final user  = FirebaseAuth.instance.currentUser!;
      final email = user.email!;
      final currentPass = _currentPassCtrl.text.trim();
      final newPass     = _newPassCtrl.text.trim();

      // Sign out and sign back in with new password
      // This avoids the Windows thread issue with reauthenticate
      final cred = EmailAuthProvider.credential(
        email:    email,
        password: currentPass,
      );

      // Step 1: reauthenticate
      await user.reauthenticateWithCredential(cred);

      // Step 2: small delay for Windows Firebase thread sync
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: update password
      await FirebaseAuth.instance.currentUser!.updatePassword(newPass);

      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();

      setState(() => _passSuccess = 'Password changed successfully!');

    } on FirebaseAuthException catch (e) {
      setState(() => _passError = _err(e.code));
    } catch (e) {
      setState(() => _passError = 'Failed to update password. Please try again.');
    } finally {
      if (mounted) setState(() => _changingPass = false);
    }
  }

  Future<void> _sendResetLink() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No email found for this account.'),
        backgroundColor: AppColors.red500,
      ));
      return;
    }
    setState(() => _sendingReset = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Password reset link sent to $email'),
          backgroundColor: AppColors.teal600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ));
      }
    } finally {
      if (mounted) setState(() => _sendingReset = false);
    }
  }

  String _err(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential': return 'Current password is incorrect.';
      case 'weak-password':      return 'New password is too weak.';
      case 'too-many-requests':  return 'Too many attempts. Try again later.';
      default: return 'Something went wrong. Please try again.';
    }
  }

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c   = context.colors;
    final user = _auth.currentUser;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('User & Security', style: TextStyle(fontSize: 20,
            fontWeight: FontWeight.w700, color: c.textPrimary)),
        const SizedBox(height: 4),
        Text('Manage your account and password.',
            style: TextStyle(fontSize: 13, color: c.textMuted)),
      ]),
      const SizedBox(height: 24),

      // ── Account Info Card ─────────────────────────────────
      _sectionTitle('Account Information', c),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.border),
        ),
        child: _loadingUser
            ? const Center(child: CircularProgressIndicator())
            : Column(children: [
          _infoRow(Icons.person_outline, 'Full Name',
              _userData?['name'] ?? user?.displayName ?? 'N/A', c),
          Divider(height: 24, color: c.borderLight),
          _infoRow(Icons.email_outlined, 'Email Address',
              user?.email ?? 'N/A', c),
          Divider(height: 24, color: c.borderLight),
          _infoRow(Icons.phone_outlined, 'Mobile Number',
              _userData?['phone'] != null
                  ? '+91 ${_userData!['phone']}'
                  : 'N/A', c),
          Divider(height: 24, color: c.borderLight),
          _infoRow(Icons.badge_outlined, 'Role',
              (_userData?['role'] as String? ?? 'cashier').toUpperCase(), c),
          Divider(height: 24, color: c.borderLight),
          _infoRow(Icons.access_time_outlined, 'Last Login',
              _userData?['lastLogin'] != null
                  ? _formatTimestamp(_userData!['lastLogin'])
                  : 'N/A', c),
        ]),
      ),

      const SizedBox(height: 28),

      // ── Change Password ───────────────────────────────────
      _sectionTitle('Change Password', c),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _passField('Current Password', _currentPassCtrl,
              _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent), c),
          const SizedBox(height: 14),
          _passField('New Password', _newPassCtrl,
              _obscureNew, () => setState(() => _obscureNew = !_obscureNew), c),
          const SizedBox(height: 14),
          _passField('Confirm New Password', _confirmPassCtrl,
              _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm), c),

          // Error / Success
          if (_passError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: AppColors.red50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.red100)),
              child: Row(children: [
                const Icon(Icons.error_outline, size: 16, color: AppColors.red500),
                const SizedBox(width: 8),
                Expanded(child: Text(_passError!, style: const TextStyle(
                    fontSize: 13, color: AppColors.red700,
                    fontWeight: FontWeight.w500))),
              ]),
            ),
          ],
          if (_passSuccess != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: AppColors.green100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0))),
              child: Row(children: [
                const Icon(Icons.check_circle_outline, size: 16, color: AppColors.green700),
                const SizedBox(width: 8),
                Text(_passSuccess!, style: const TextStyle(
                    fontSize: 13, color: AppColors.green700,
                    fontWeight: FontWeight.w500)),
              ]),
            ),
          ],

          const SizedBox(height: 18),
          Row(children: [
            ElevatedButton(
              onPressed: _changingPass ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal600,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              child: _changingPass
                  ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                  : const Text('Update Password'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _sendingReset ? null : _sendResetLink,
              icon: _sendingReset
                  ? const SizedBox(width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.email_outlined, size: 16),
              label: const Text('Send Reset Link to Email'),
              style: OutlinedButton.styleFrom(
                foregroundColor: c.textSecond,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                side: BorderSide(color: c.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ]),
      ),
    ]);
  }

  Widget _infoRow(IconData icon, String label, String value, AdaptiveColors c) =>
      Row(children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(color: c.inputFill,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: AppColors.teal600)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: c.textMuted,
              fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, color: c.textPrimary,
              fontWeight: FontWeight.w600)),
        ])),
      ]);

  Widget _passField(String label, TextEditingController ctrl,
      bool obscure, VoidCallback toggle, AdaptiveColors c) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: c.textSecond)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          onChanged: (_) => setState(() { _passError = null; _passSuccess = null; }),
          decoration: InputDecoration(
            filled: true, fillColor: c.inputFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: c.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: c.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.teal600, width: 2)),
            hintText: 'Enter $label',
            hintStyle: TextStyle(fontSize: 13, color: c.textMuted),
            suffixIcon: IconButton(
              icon: Icon(obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
                  size: 18, color: c.textMuted),
              onPressed: toggle,
            ),
          ),
          style: TextStyle(fontSize: 14, color: c.textPrimary),
        ),
      ]);

  Widget _sectionTitle(String title, AdaptiveColors c) => Row(children: [
    Text(title.toUpperCase(), style: TextStyle(fontSize: 11,
        fontWeight: FontWeight.w700, color: c.textPrimary, letterSpacing: 0.8)),
    const SizedBox(width: 12),
    Expanded(child: Divider(color: c.borderLight)),
  ]);

  String _formatTimestamp(dynamic ts) {
    try {
      final dt = (ts as dynamic).toDate() as DateTime;
      return '${dt.day}/${dt.month}/${dt.year}  '
          '${dt.hour > 12 ? dt.hour - 12 : dt.hour}:'
          '${dt.minute.toString().padLeft(2,'0')} '
          '${dt.hour >= 12 ? 'PM' : 'AM'}';
    } catch (_) {
      return 'N/A';
    }
  }
}


// ═════════════════════════════════════════════════════════════
//  TAB 5 — BACKUP & SYNC
// ═════════════════════════════════════════════════════════════
class _SyncTab extends StatefulWidget {
  final SettingsModel settings;
  final Future<void> Function(SettingsModel) onSave;
  const _SyncTab({required this.settings, required this.onSave});
  @override State<_SyncTab> createState() => _SyncTabState();
}
class _SyncTabState extends State<_SyncTab> {
  late bool   _auto   = widget.settings.autoSync;
  late bool   _wifi   = widget.settings.wifiOnly;
  late bool   _backup = widget.settings.autoBackup;
  late String _freq   = widget.settings.syncFrequency;
  bool _saving = false;
  bool _busy   = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSave(widget.settings.copyWith(
      autoSync:      _auto,
      wifiOnly:      _wifi,
      autoBackup:    _backup,
      syncFrequency: _freq,
      updatedAt:     DateTime.now(),
    ));
    if (mounted) setState(() => _saving = false);
  }

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
              decoration: BoxDecoration(color: AppColors.teal600,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.cloud_done_outlined,
                  color: AppColors.white, size: 22)),
          const SizedBox(width: 14),
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Firebase Sync — Not Connected Yet',
                  style: TextStyle(fontWeight: FontWeight.w600,
                      fontSize: 14, color: AppColors.teal700)),
              SizedBox(height: 2),
              Text('Will sync automatically once Firebase is configured',
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
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.white))
                : const Icon(Icons.sync, size: 16),
            label: Text(_busy ? 'Syncing...' : 'Sync Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal600,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      _TogCard('Auto Sync',
          'Automatically sync data to Firebase in background',
          _auto, (v) => setState(() => _auto = v)),
      const SizedBox(height: 12),
      _TogCard('Sync on Wi-Fi Only',
          'Prevent syncing over metered connections',
          _wifi, (v) => setState(() => _wifi = v)),
      const SizedBox(height: 16),
      SizedBox(width: 320, child: _DDField('Sync Frequency', _freq,
          ['Every minute','Every 5 minutes','Every 15 minutes',
            'Every hour','Manual only'],
              (v) => setState(() => _freq = v ?? _freq))),
      const SizedBox(height: 24),
      _SecDiv('Local Backup'),
      const SizedBox(height: 14),
      _TogCard('Auto Backup on Close',
          'Save a local backup every time the app is closed',
          _backup, (v) => setState(() => _backup = v)),
      const SizedBox(height: 32),
      _SaveBtn(_save, _saving),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════
//  TAB 6 — PRINTER SETTINGS
// ═════════════════════════════════════════════════════════════
class _PrinterTab extends StatefulWidget {
  final SettingsModel settings;
  final Future<void> Function(SettingsModel) onSave;
  const _PrinterTab({required this.settings, required this.onSave});
  @override State<_PrinterTab> createState() => _PrinterTabState();
}
class _PrinterTabState extends State<_PrinterTab> {
  late String _printer = widget.settings.printerName;
  late String _paper   = widget.settings.paperSize;
  late bool   _auto    = widget.settings.autoPrint;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSave(widget.settings.copyWith(
      printerName: _printer,
      paperSize:   _paper,
      autoPrint:   _auto,
      updatedAt:   DateTime.now(),
    ));
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header('Hardware & Printers', 'Connect thermal printers and cash drawers.'),
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
      const SizedBox(height: 32),
      _SaveBtn(_save, _saving),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════
//  TAB 7 — SYSTEM SETTINGS
// ═════════════════════════════════════════════════════════════
class _SystemTab extends StatefulWidget {
  final SettingsModel settings;
  final Future<void> Function(SettingsModel) onSave;
  const _SystemTab({required this.settings, required this.onSave});
  @override State<_SystemTab> createState() => _SystemTabState();
}
class _SystemTabState extends State<_SystemTab> {
  late String _lang = widget.settings.language;
  late String _date = widget.settings.dateFormat;
  late String _time = widget.settings.timeFormat;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    final isDark = appThemeNotifier.value == ThemeMode.dark;
    await widget.onSave(widget.settings.copyWith(
      language:  _lang,
      dateFormat:_date,
      timeFormat:_time,
      themeMode: isDark ? 'dark' : 'light',
      updatedAt: DateTime.now(),
    ));
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Header('System Preferences', 'Customize interface and localization.'),
          const SizedBox(height: 24),
          _Lbl('Interface Theme'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _ThemeCard('Light Mode', Icons.wb_sunny_outlined,
                const Color(0xFFF59E0B), null, !isDark,
                    () => appThemeNotifier.value = ThemeMode.light)),
            const SizedBox(width: 16),
            Expanded(child: _ThemeCard('Dark Mode', Icons.dark_mode_outlined,
                AppColors.white, AppColors.slate900, isDark,
                    () => appThemeNotifier.value = ThemeMode.dark)),
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
          SizedBox(width: 320, child: _DDField('Time Format', _time,
              ['12-hour (AM/PM)','24-hour'],
                  (v) => setState(() => _time = v ?? _time))),
          const SizedBox(height: 32),
          _SaveBtn(_save, _saving),
        ]);
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  SHARED COMPONENTS
// ═════════════════════════════════════════════════════════════

class _RailTile extends StatefulWidget {
  final _Tab tab; final bool active; final VoidCallback onTap;
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
            color: a ? AppColors.teal600
                : (_hov ? context.colors.borderLight : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(widget.tab.icon, size: 17,
                color: a ? AppColors.white : AppColors.gray500),
            const SizedBox(width: 10),
            Text(widget.tab.label, style: TextStyle(fontSize: 13,
                fontWeight: a ? FontWeight.w600 : FontWeight.w500,
                color: a ? AppColors.white : AppColors.gray600)),
          ]),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title, sub;
  const _Header(this.title, this.sub);
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
          color: c.textPrimary)),
      const SizedBox(height: 4),
      Text(sub, style: TextStyle(fontSize: 13, color: c.textMuted)),
    ]);
  }
}

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
      _Lbl(label), const SizedBox(height: 6),
      _TF(ctrl: ctrl, lines: lines, obscure: obscure),
    ],
  );
}

class _Row2 extends StatelessWidget {
  final Widget a, b;
  const _Row2(this.a, this.b);
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [Expanded(child: a), const SizedBox(width: 16), Expanded(child: b)],
  );
}

Widget _DDField(String label, String value, List<String> items,
    ValueChanged<String?> onChanged) {
  return Builder(builder: (context) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Lbl(label), const SizedBox(height: 6),
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: c.inputFill, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.border),
        ),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: value, isExpanded: true, dropdownColor: c.cardBg,
          items: items.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: TextStyle(fontSize: 14, color: c.textPrimary),
                  overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: c.textMuted),
          style: TextStyle(fontSize: 14, color: c.textPrimary),
        )),
      ),
    ]);
  });
}

Widget _TogCard(String title, String sub, bool val, ValueChanged<bool> onChange) {
  return Builder(builder: (context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.cardBg, borderRadius: BorderRadius.circular(10),
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
          border: Border.all(
              color: sel ? AppColors.teal600 : c.border, width: sel ? 2 : 1),
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
    );
  });
}

Widget _ThemeCard(String label, IconData icon, Color iconColor,
    Color? iconBg, bool sel, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: sel ? AppColors.teal50 : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: sel ? AppColors.teal600 : AppColors.gray200,
            width: sel ? 2 : 1),
      ),
      child: Column(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
              color: iconBg ?? const Color(0xFFFEF3C7),
              shape: BoxShape.circle),
          child: Icon(icon, size: 24, color: iconColor),
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
            color: sel ? AppColors.teal700 : AppColors.gray700)),
      ]),
    ),
  );
}

class _SecDiv extends StatelessWidget {
  final String label;
  const _SecDiv(this.label);
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
        color: context.colors.textPrimary)),
    const SizedBox(width: 12),
    Expanded(child: Divider(color: context.colors.border)),
  ]);
}

class _Lbl extends StatelessWidget {
  final String t;
  const _Lbl(this.t);
  @override
  Widget build(BuildContext context) => Text(t,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: context.colors.textSecond));
}

Widget _TF({
  required TextEditingController ctrl,
  String? hint, int lines = 1, bool obscure = false,
  TextInputType? keyboard,
}) => Builder(builder: (context) {
  final c = context.colors;
  return TextField(
    controller: ctrl, maxLines: lines,
    obscureText: obscure, keyboardType: keyboard,
    decoration: InputDecoration(
      hintText: hint, filled: true, fillColor: c.inputFill,
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

Widget _SaveBtn(Future<void> Function() onSave, bool saving) =>
    ElevatedButton(
      onPressed: saving ? null : onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal600,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      child: saving
          ? const SizedBox(width: 18, height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
          : const Text('Save Changes'),
    );