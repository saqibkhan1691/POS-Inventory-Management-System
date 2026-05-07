import 'package:flutter/material.dart';
import 'theme.dart';
import 'routes.dart';
import '../screens/login_screen.dart';
import '../screens/billing_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/add_product_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';

/// ─────────────────────────────────────────────────────────────
///  APP.DART  –  lib/core/app.dart
/// ─────────────────────────────────────────────────────────────
class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shree Sarees POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (ctx) => LoginScreen(
          onLoginSuccess: () => Navigator.pushReplacementNamed(ctx, AppRoutes.billing),
        ),
        AppRoutes.billing:      (_) => const AppShell(activeRoute: AppRoutes.billing),
        AppRoutes.addProduct:   (_) => const AppShell(activeRoute: AppRoutes.addProduct),
        AppRoutes.inventory:    (_) => const AppShell(activeRoute: AppRoutes.inventory),
        AppRoutes.payment:      (_) => const AppShell(activeRoute: AppRoutes.payment),
        AppRoutes.transactions: (_) => const AppShell(activeRoute: AppRoutes.transactions),
        AppRoutes.settings:     (_) => const AppShell(activeRoute: AppRoutes.settings),
      },
    );
  }
}

class AppShell extends StatelessWidget {
  final String activeRoute;
  const AppShell({super.key, required this.activeRoute});

  Widget _buildPage() {
    switch (activeRoute) {
      case AppRoutes.billing:      return const BillingScreen();
      case AppRoutes.inventory:    return const InventoryScreen();
      case AppRoutes.addProduct:   return const AddProductScreen();
      case AppRoutes.payment:      return const PaymentScreen();
      case AppRoutes.transactions: return const TransactionsScreen();
      case AppRoutes.settings:     return const SettingsScreen();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction_outlined, size: 52, color: AppColors.gray300),
              const SizedBox(height: 12),
              Text('Screen coming soon…',
                  style: AppTextStyles.body.copyWith(color: AppColors.gray400)),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Row(
        children: [
          AppSidebar(
            activeRoute: activeRoute,
            onRouteSelected: (route) {
              if (route == AppRoutes.login) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              } else {
                Navigator.pushReplacementNamed(context, route);
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                const AppTopBar(),
                Expanded(
                  child: Container(
                    color: AppColors.gray50,
                    padding: const EdgeInsets.all(20),
                    child: _buildPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
