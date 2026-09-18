import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';
import '../core/routes.dart';
import '../core/app_localizations.dart';
import '../core/app_settings_notifier.dart';
import 'logout_dialog.dart';

/// ─────────────────────────────────────────────────────────────
///  SIDEBAR — Updated with language support
/// ─────────────────────────────────────────────────────────────
class AppSidebar extends StatelessWidget {
  final String activeRoute;
  final ValueChanged<String> onRouteSelected;
  const AppSidebar({
    super.key,
    required this.activeRoute,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuild when language changes
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, lang, _) {
        final l10n = AppLocalizations(lang);
        return _SidebarContent(
          activeRoute:     activeRoute,
          onRouteSelected: onRouteSelected,
          l10n:            l10n,
        );
      },
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final String activeRoute;
  final ValueChanged<String> onRouteSelected;
  final AppLocalizations l10n;
  const _SidebarContent({
    required this.activeRoute,
    required this.onRouteSelected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final items = [
      _SidebarItem(
          route: AppRoutes.billing,
          label: l10n.billing,
          icon:  Icons.receipt_long_outlined),
      _SidebarItem(
          route: AppRoutes.addProduct,
          label: l10n.addProduct,
          icon:  Icons.add_box_outlined),
      _SidebarItem(
          route: AppRoutes.inventory,
          label: l10n.inventory,
          icon:  Icons.inventory_2_outlined),
      _SidebarItem(
          route: AppRoutes.transactions,
          label: l10n.transactions,
          icon:  Icons.swap_horiz_outlined),
      _SidebarItem(
          route: AppRoutes.settings,
          label: l10n.settings,
          icon:  Icons.settings_outlined),
    ];

    return Container(
      width: 230,
      color: AppColors.slate900,
      child: Column(children: [
        // Brand header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.teal600,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.storefront_outlined,
                  color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SHREE SAREES', style: TextStyle(
                    color: AppColors.white, fontSize: 13,
                    fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                Text('POS System', style: TextStyle(
                    color: AppColors.slate400, fontSize: 11)),
              ],
            )),
          ]),
        ),

        Divider(height: 1, color: AppColors.slate800),
        const SizedBox(height: 8),

        // Nav items
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: items.map((item) => _NavTile(
                item:     item,
                active:   activeRoute == item.route,
                onTap:    () => onRouteSelected(item.route),
              )).toList(),
            ),
          ),
        ),

        // Logout
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
          child: _LogoutTile(
            label: l10n.logout,
            onTap: () => LogoutDialog.show(
              context,
              onConfirm: () => onRouteSelected(AppRoutes.login),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SidebarItem {
  final String route, label;
  final IconData icon;
  const _SidebarItem({
    required this.route,
    required this.label,
    required this.icon,
  });
}

class _NavTile extends StatefulWidget {
  final _SidebarItem item;
  final bool active;
  final VoidCallback onTap;
  const _NavTile({required this.item, required this.active, required this.onTap});
  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: a
                ? AppColors.teal600
                : (_hov
                ? AppColors.slate800
                : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(widget.item.icon, size: 18,
                color: a ? AppColors.white : AppColors.slate400),
            const SizedBox(width: 10),
            Text(widget.item.label, style: TextStyle(
                fontSize: 13,
                fontWeight: a ? FontWeight.w600 : FontWeight.w500,
                color: a ? AppColors.white : AppColors.slate300)),
          ]),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _LogoutTile({required this.label, required this.onTap});
  @override
  State<_LogoutTile> createState() => _LogoutTileState();
}

class _LogoutTileState extends State<_LogoutTile> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: _hov ? AppColors.red500.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: _hov
                ? Border.all(color: AppColors.red500.withOpacity(0.3))
                : null,
          ),
          child: Row(children: [
            Icon(Icons.logout_outlined, size: 18,
                color: _hov ? AppColors.red400 : AppColors.slate500),
            const SizedBox(width: 10),
            Text(widget.label, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500,
                color: _hov ? AppColors.red400 : AppColors.slate400)),
          ]),
        ),
      ),
    );
  }
}