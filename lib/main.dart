import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/app.dart';
import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // DB initialize karo — tables + seed data first run pe
  await DbHelper.instance.database;

  runApp(const POSApp());
<<<<<<< HEAD
}

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page:'),
=======
      title: 'Shree Sarees POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppShell(),
>>>>>>> 61591e0 (updated ui structure and add content in it)
    );
  }
}

/// ─────────────────────────────────────────────────────────────
///  APP SHELL  –  Root widget that holds the sidebar + topbar
///  and swaps the active screen.
/// ─────────────────────────────────────────────────────────────
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool   _isLoggedIn   = false;
  String _activeRoute  = AppRoutes.billing;

  void _navigate(String route) {
    if (route == AppRoutes.login) {
      setState(() => _isLoggedIn = false);
    } else {
      setState(() => _activeRoute = route);
    }
  }

  Widget _buildScreen() {
    switch (_activeRoute) {
      case AppRoutes.billing:    return const BillingScreen();
      case AppRoutes.inventory:  return const InventoryScreen();
      case AppRoutes.addProduct: return const AddProductScreen();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction_outlined,
                  size: 48, color: AppColors.gray300),
              const SizedBox(height: 12),
              Text('Screen not yet implemented',
                  style: AppTextStyles.body.copyWith(color: AppColors.gray400)),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show login screen if not authenticated
    if (!_isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: () => setState(() => _isLoggedIn = true),
      );
    }

    // Main desktop layout
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Row(
        children: [
          // ── Sidebar ─────────────────────────────────────
          AppSidebar(
            activeRoute: _activeRoute,
            onRouteSelected: _navigate,
          ),

          // ── Content area ─────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top bar
                const AppTopBar(),

                // Page content
                Expanded(
                  child: Container(
                    color: AppColors.gray50,
                    padding: const EdgeInsets.all(20),
                    child: _buildScreen(),
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
=======
}
>>>>>>> b384a73 (add SQLite database)
