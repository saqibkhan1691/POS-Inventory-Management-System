/// ─────────────────────────────────────────────────────────────
///  ROUTES  –  lib/core/routes.dart
/// ─────────────────────────────────────────────────────────────
class AppRoutes {
  // ── Navigator routes (used in MaterialApp.routes) ──────────
  static const login = '/login';
  static const shell = '/shell'; // ← single shell, screens switch via setState

  // ── Internal screen IDs (used by AppShell setState) ────────
  static const billing      = '/billing';
  static const addProduct   = '/add-product';
  static const inventory    = '/inventory';
  static const payment      = '/payment';
  static const transactions = '/transactions';
  static const settings     = '/settings';
}