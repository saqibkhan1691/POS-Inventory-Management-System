import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';

/// ─────────────────────────────────────────────────────────────
///  LOGIN SCREEN  –  lib/screens/login_screen.dart
///  Firebase Authentication — Email/Password
///  Two modes: Login + Register (new account)
/// ─────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _nameCtrl     = TextEditingController(); // only for register
  final _formKey      = GlobalKey<FormState>();

  bool _loading   = false;
  bool _obscure   = true;
  bool _isRegister= false; // toggle between login/register
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── Firebase Login ────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      if (mounted) widget.onLoginSuccess();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _friendlyError(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Firebase Register ─────────────────────────────────────
  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      // Save display name
      await cred.user?.updateDisplayName(_nameCtrl.text.trim());
      if (mounted) widget.onLoginSuccess();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _friendlyError(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Friendly error messages ───────────────────────────────
  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':       return 'No account found with this email.';
      case 'wrong-password':       return 'Incorrect password. Please try again.';
      case 'invalid-email':        return 'Please enter a valid email address.';
      case 'email-already-in-use': return 'This email is already registered.';
      case 'weak-password':        return 'Password must be at least 6 characters.';
      case 'too-many-requests':    return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'No internet connection.';
      default: return 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Brand ──────────────────────────────────
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.teal600,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(
                        color: AppColors.teal600.withOpacity(0.4),
                        blurRadius: 32, spreadRadius: 2)],
                  ),
                  child: const Icon(Icons.storefront_outlined,
                      color: AppColors.white, size: 34),
                ),
                const SizedBox(height: 20),
                const Text('SHREE SAREES',
                    style: TextStyle(color: AppColors.white,
                        fontSize: 26, fontWeight: FontWeight.w800,
                        letterSpacing: 1.2)),
                const SizedBox(height: 6),
                const Text('POS SYSTEM',
                    style: TextStyle(color: AppColors.slate400,
                        fontSize: 11, fontWeight: FontWeight.w600,
                        letterSpacing: 2.5)),
                const SizedBox(height: 36),

                // ── Card ───────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 40, offset: const Offset(0, 12))],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: [
                    // Teal top bar
                    Container(height: 4,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppColors.teal600, AppColors.teal700]),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Row(children: [
                                Icon(_isRegister
                                    ? Icons.person_add_outlined
                                    : Icons.lock_outline,
                                    size: 18, color: AppColors.gray400),
                                const SizedBox(width: 8),
                                Text(_isRegister
                                    ? 'Create Account'
                                    : 'Secure Login',
                                    style: AppTextStyles.h2.copyWith(
                                        fontWeight: FontWeight.w700)),
                              ]),
                              const SizedBox(height: 6),
                              Text(
                                _isRegister
                                    ? 'Register to access the POS system'
                                    : 'Sign in to your account',
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.gray400),
                              ),
                              const SizedBox(height: 24),

                              // Name field (register only)
                              if (_isRegister) ...[
                                _FieldLabel('Full Name'),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _nameCtrl,
                                  decoration: _deco('Enter your full name',
                                      Icons.person_outline),
                                  validator: (v) => (v?.trim().isEmpty ?? true)
                                      ? 'Please enter your name' : null,
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Email
                              _FieldLabel('Email Address'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: _deco('Enter your email',
                                    Icons.email_outlined),
                                validator: (v) {
                                  if (v?.trim().isEmpty ?? true) {
                                    return 'Please enter your email';
                                  }
                                  if (!v!.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password
                              _FieldLabel('Password'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _isRegister
                                    ? _handleRegister()
                                    : _handleLogin(),
                                decoration: _deco('Enter your password',
                                    Icons.lock_outline).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 18, color: AppColors.gray400),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) {
                                  if (v?.isEmpty ?? true) {
                                    return 'Please enter your password';
                                  }
                                  if (_isRegister && v!.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              // Error message
                              if (_error != null) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.red50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.red100),
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.error_outline,
                                        size: 16, color: AppColors.red500),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(_error!,
                                        style: const TextStyle(fontSize: 13,
                                            color: AppColors.red700,
                                            fontWeight: FontWeight.w500))),
                                  ]),
                                ),
                              ],

                              const SizedBox(height: 24),

                              // Submit button
                              SizedBox(
                                width: double.infinity, height: 50,
                                child: ElevatedButton(
                                  onPressed: _loading
                                      ? null
                                      : (_isRegister
                                      ? _handleRegister
                                      : _handleLogin),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.teal600,
                                    foregroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    textStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                    elevation: 0,
                                  ),
                                  child: _loading
                                      ? const SizedBox(width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.white))
                                      : Text(_isRegister
                                      ? 'Create Account'
                                      : 'Login'),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Toggle login/register
                              Center(child: GestureDetector(
                                onTap: () => setState(() {
                                  _isRegister = !_isRegister;
                                  _error = null;
                                  _formKey.currentState?.reset();
                                }),
                                child: RichText(text: TextSpan(
                                  style: const TextStyle(fontSize: 13,
                                      color: AppColors.gray500),
                                  children: [
                                    TextSpan(text: _isRegister
                                        ? 'Already have an account? '
                                        : "Don't have an account? "),
                                    TextSpan(
                                      text: _isRegister ? 'Login' : 'Register',
                                      style: const TextStyle(
                                          color: AppColors.teal600,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                )),
                              )),

                              // Forgot password (login mode only)
                              if (!_isRegister) ...[
                                const SizedBox(height: 8),
                                Center(child: TextButton(
                                  onPressed: _forgotPassword,
                                  child: const Text('Forgot Password?',
                                      style: TextStyle(color: AppColors.gray400,
                                          fontSize: 13)),
                                )),
                              ],
                            ]),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 28),
                const Text('Version 2.4.1  •  Shree Sarees POS',
                    style: TextStyle(color: AppColors.slate500, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Forgot password ───────────────────────────────────────
  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Enter your email first to reset password.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Password reset email sent!'),
          backgroundColor: AppColors.teal600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _friendlyError(e.code));
    }
  }

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 18, color: AppColors.gray400),
    filled: true,
    fillColor: AppColors.gray50,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.gray200)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.gray200)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.teal600, width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.red500)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.red500, width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    hintStyle: const TextStyle(fontSize: 14, color: AppColors.gray400),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.gray700));
}