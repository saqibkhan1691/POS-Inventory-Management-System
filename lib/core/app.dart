import 'package:flutter/material.dart';
import 'theme.dart';
import 'theme_provider.dart';
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

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Shree Sarees POS',
          debugShowCheckedModeBanner: false,
          theme:     AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          initialRoute: AppRoutes.login,
          routes: {
            AppRoutes.login: (_) => const _LoginGate(),
            AppRoutes.shell: (_) => const AppShell(),
          },
        );
      },
    );
  }
}

class _LoginGate extends StatelessWidget {
  const _LoginGate();
  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      onLoginSuccess: () =>
          Navigator.pushReplacementNamed(context, AppRoutes.shell),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _route = AppRoutes.billing;

  void _go(String route) {
    if (route == AppRoutes.login) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }
    setState(() => _route = route);
  }

  Widget _page() {
    switch (_route) {
      case AppRoutes.billing:      return const BillingScreen();
      case AppRoutes.inventory:    return const InventoryScreen();
      case AppRoutes.addProduct:   return const AddProductScreen();
      case AppRoutes.payment:      return const PaymentScreen();
      case AppRoutes.transactions: return const TransactionsScreen();
      case AppRoutes.settings:     return const SettingsScreen();
      default:
        return const Center(
          child: Text('Coming soon…',
              style: TextStyle(color: AppColors.gray400, fontSize: 16)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme.of(context) is live — updates when appThemeNotifier changes
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      // Use theme surface color — not hardcoded AppColors
      backgroundColor: cs.background,
      body: Row(
        children: [
          AppSidebar(activeRoute: _route, onRouteSelected: _go),
          Expanded(
            child: Column(
              children: [
                const AppTopBar(),
                Expanded(
                  child: Container(
                    color: cs.background,
                    padding: const EdgeInsets.all(20),
                    child: _page(),
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