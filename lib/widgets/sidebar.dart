import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/routes.dart';

/// ─────────────────────────────────────────────────────────────
///  SIDEBAR  –  Persistent left navigation for Desktop POS
///  Width: 240 px, Slate-900 dark background
/// ─────────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem({required this.label, required this.icon, required this.route});
}

const _navItems = [
  _NavItem(label: 'Billing',       icon: Icons.calculate_outlined,      route: AppRoutes.billing),
  _NavItem(label: 'Add Product',   icon: Icons.add_box_outlined,        route: AppRoutes.addProduct),
  _NavItem(label: 'Inventory',     icon: Icons.inventory_2_outlined,    route: AppRoutes.inventory),
  _NavItem(label: 'Transactions',  icon: Icons.receipt_long_outlined,   route: AppRoutes.transactions),
  _NavItem(label: 'Reports',       icon: Icons.bar_chart_outlined,      route: '/reports'),
  _NavItem(label: 'Settings',      icon: Icons.settings_outlined,       route: AppRoutes.settings),
];

class AppSidebar extends StatelessWidget {
  /// The current active route (e.g. AppRoutes.billing)
  final String activeRoute;
  final ValueChanged<String> onRouteSelected;

  const AppSidebar({
    super.key,
    required this.activeRoute,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppColors.slate900,
      child: Column(
        children: [
          // ── Logo / Store name ──────────────────────────────
          Container(
            height: 64,
            color: AppColors.slate950,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.storefront_outlined, color: AppColors.teal600, size: 22),
                const SizedBox(width: 10),
                const Text(
                  'SHREE SAREES',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),

          // ── Nav items ──────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                children: _navItems
                    .map((item) => _NavTile(
                  item: item,
                  isActive: activeRoute == item.route,
                  onTap: () => onRouteSelected(item.route),
                ))
                    .toList(),
              ),
            ),
          ),

          // ── Logout ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.slate800)),
            ),
            child: _NavTile(
              item: const _NavItem(
                  label: 'Logout', icon: Icons.logout_outlined, route: AppRoutes.login),
              isActive: false,
              isDanger: true,
              onTap: () => onRouteSelected(AppRoutes.login),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual nav tile ────────────────────────────────────────────────────────
class _NavTile extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final bool isDanger;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    if (widget.isActive) {
      bg = AppColors.teal600;
      fg = AppColors.white;
    } else if (_hovered && widget.isDanger) {
      bg = const Color(0x1AEF4444); // red/10
      fg = AppColors.red500;
    } else if (_hovered) {
      bg = AppColors.slate800;
      fg = AppColors.white;
    } else {
      bg = Colors.transparent;
      fg = AppColors.slate300;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, size: 20, color: fg),
              const SizedBox(width: 12),
              Text(
                widget.item.label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
