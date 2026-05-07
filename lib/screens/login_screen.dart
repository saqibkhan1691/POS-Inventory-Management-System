import 'package:flutter/material.dart';
import '../core/theme.dart';

/// ─────────────────────────────────────────────────────────────
///  LOGIN SCREEN  –  Full-screen auth page (slate-900 bg)
///  File: lib/screens/login_screen.dart
/// ─────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  /// Called when login succeeds – parent should navigate to billing
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController(text: '12345');
  bool _loading   = false;
  bool _obscure   = true;

  void _handleLogin() async {
    setState(() => _loading = true);
    // Simulate short auth delay (replace with real auth later)
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _loading = false);
      widget.onLoginSuccess();
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Brand mark ──────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.teal600,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal600.withOpacity(0.35),
                      blurRadius: 30,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: const Icon(Icons.storefront_outlined,
                    color: AppColors.white, size: 30),
              ),
              const SizedBox(height: 20),
              const Text(
                'SHREE SAREES',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'POS SYSTEM',
                style: TextStyle(
                  color: AppColors.slate400,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.5,
                ),
              ),

              const SizedBox(height: 36),

              // ── Card ────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Teal accent bar
                    Container(
                      height: 4,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.teal600, AppColors.teal700],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Row(
                            children: [
                              const Icon(Icons.lock_outline,
                                  size: 18, color: AppColors.gray400),
                              const SizedBox(width: 8),
                              Text('Secure Login',
                                  style: AppTextStyles.h2
                                      .copyWith(fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Username
                          _FieldLabel('Terminal / Username'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _userCtrl,
                            decoration: _fieldDecoration('admin'),
                            style: const TextStyle(fontSize: 14),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 18),

                          // Password
                          _FieldLabel('PIN / Password'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            onSubmitted: (_) => _handleLogin(),
                            decoration: _fieldDecoration('••••••').copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                  color: AppColors.gray400,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 28),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teal600,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9)),
                                textStyle: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white),
                              )
                                  : const Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text('Login to Terminal'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Forgot password
                          Center(
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                    color: AppColors.teal600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text('Version 2.4.1 (Build 4920)',
                  style: TextStyle(color: AppColors.slate500, fontSize: 12)),
              const SizedBox(height: 4),
              const Text('© 2026 RetailSys Enterprise Solutions',
                  style: TextStyle(color: AppColors.slate500, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.gray50,
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
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700),
    );
  }
}
