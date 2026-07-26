import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';

/// ─────────────────────────────────────────────────────────────
///  LOGIN SCREEN v2  –  lib/screens/login_screen.dart
///  Firebase Auth — Email/Password + Phone OTP
///  Features:
///    - Login (email + password) with Remember Me
///    - Register (name, email, phone, password, confirm password)
///    - Phone OTP verification on register
///    - Forgot Password (email reset)
///    - Login button disabled until user types something
///    - Last login info stored in Firebase Auth
/// ─────────────────────────────────────────────────────────────

enum _Mode { login, register, forgotPassword, otpVerify }

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth    = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _otpCtrl     = TextEditingController();
  final _resetCtrl   = TextEditingController(); // forgot password email

  _Mode  _mode       = _Mode.login;
  bool   _loading    = false;
  bool   _obscureP   = true;
  bool   _obscureC   = true;
  bool   _rememberMe = false;
  bool   _hasInput   = false; // login button enabler
  String? _error;
  String? _verificationId; // for phone OTP

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
    // Listen to any field change to enable login button
    _emailCtrl.addListener(_checkInput);
    _passCtrl.addListener(_checkInput);
  }

  void _checkInput() {
    final has = _emailCtrl.text.isNotEmpty || _passCtrl.text.isNotEmpty;
    if (has != _hasInput) setState(() => _hasInput = has);
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final remembered = prefs.getBool('remember_me') ?? false;
    final savedEmail = prefs.getString('saved_email') ?? '';
    if (remembered && savedEmail.isNotEmpty) {
      setState(() {
        _rememberMe = true;
        _emailCtrl.text = savedEmail;
      });
    }
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_email', _emailCtrl.text.trim());
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('saved_email');
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _passCtrl,
      _confirmCtrl, _otpCtrl, _resetCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── LOGIN ─────────────────────────────────────────────────
  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.signInWithEmailAndPassword(
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      await _saveRememberMe();
      if (mounted) widget.onLoginSuccess();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _err(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── REGISTER — Step 1: create account ────────────────────
  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });
    try {
      // Create Firebase Auth user
      final cred = await _auth.createUserWithEmailAndPassword(
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      // Save display name
      await cred.user?.updateDisplayName(_nameCtrl.text.trim());

      // Send phone OTP
      await _sendOtp();
    } on FirebaseAuthException catch (e) {
      setState(() { _error = _err(e.code); _loading = false; });
    }
  }

  // ── PHONE OTP — send ─────────────────────────────────────
  Future<void> _sendOtp() async {
    final phone = '+91${_phoneCtrl.text.trim()}'; // India default
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential cred) async {
        // Auto-verify on some Android devices
        await _auth.currentUser?.linkWithCredential(cred);
        if (mounted) {
          _showSnack('Phone verified automatically!', AppColors.teal600);
          widget.onLoginSuccess();
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _error   = 'Phone verification failed: ${e.message}';
          _loading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _mode           = _Mode.otpVerify;
          _loading        = false;
        });
      },
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
    );
  }

  // ── PHONE OTP — verify ────────────────────────────────────
  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.trim().length != 6) {
      setState(() => _error = 'Please enter the 6-digit OTP');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode:        _otpCtrl.text.trim(),
      );
      await _auth.currentUser?.linkWithCredential(cred);
      if (mounted) {
        _showSnack('Account created successfully!', AppColors.teal600);
        widget.onLoginSuccess();
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _err(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── FORGOT PASSWORD ───────────────────────────────────────
  Future<void> _sendResetEmail() async {
    if (_resetCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your email address');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.sendPasswordResetEmail(email: _resetCtrl.text.trim());
      if (mounted) {
        _showSnack('Password reset email sent!', AppColors.teal600);
        setState(() => _mode = _Mode.login);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _err(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  String _err(String code) {
    switch (code) {
      case 'user-not-found':        return 'No account found with this email.';
      case 'wrong-password':        return 'Incorrect password.';
      case 'invalid-credential':    return 'Invalid email or password.';
      case 'invalid-email':         return 'Please enter a valid email.';
      case 'email-already-in-use':  return 'This email is already registered.';
      case 'weak-password':         return 'Password must be at least 6 characters.';
      case 'too-many-requests':     return 'Too many attempts. Try again later.';
      case 'network-request-failed':return 'No internet connection.';
      case 'invalid-verification-code': return 'Wrong OTP. Please try again.';
      case 'credential-already-in-use': return 'This phone number is already linked.';
      default: return 'Something went wrong. Please try again.';
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: SizedBox(
            width: 440,
            child: Column(children: [
              // Brand
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.teal600,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: AppColors.teal600.withOpacity(0.4),
                      blurRadius: 32, spreadRadius: 2)],
                ),
                child: const Icon(Icons.storefront_outlined,
                    color: AppColors.white, size: 34),
              ),
              const SizedBox(height: 18),
              const Text('SHREE SAREES',
                  style: TextStyle(color: AppColors.white,
                      fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              const SizedBox(height: 6),
              const Text('POS SYSTEM',
                  style: TextStyle(color: AppColors.slate400,
                      fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2.5)),
              const SizedBox(height: 32),

              // Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3),
                      blurRadius: 40, offset: const Offset(0, 12))],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(children: [
                  Container(height: 4, decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.teal600, AppColors.teal700]))),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: _buildContent(),
                  ),
                ]),
              ),

              const SizedBox(height: 28),
              const Text('Version 2.4.1  •  Shree Sarees POS',
                  style: TextStyle(color: AppColors.slate500, fontSize: 12)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_mode) {
      case _Mode.login:         return _buildLogin();
      case _Mode.register:      return _buildRegister();
      case _Mode.forgotPassword:return _buildForgotPassword();
      case _Mode.otpVerify:     return _buildOtpVerify();
    }
  }

  // ── LOGIN FORM ────────────────────────────────────────────
  Widget _buildLogin() {
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title(Icons.lock_outline, 'Secure Login', 'Sign in to your account'),
        const SizedBox(height: 24),

        _label('Email Address'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: _deco('Enter your email', Icons.email_outlined),
          validator: (v) {
            if (v?.trim().isEmpty ?? true) return 'Please enter email';
            if (!v!.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 16),

        _label('Password'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passCtrl,
          obscureText: _obscureP,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) { if (_hasInput) _login(); },
          decoration: _deco('Enter your password', Icons.lock_outline).copyWith(
            suffixIcon: _eyeBtn(_obscureP, () =>
                setState(() => _obscureP = !_obscureP)),
          ),
          validator: (v) {
            if (v?.isEmpty ?? true) return 'Please enter password';
            return null;
          },
        ),
        const SizedBox(height: 14),

        // Remember me
        Row(children: [
          SizedBox(width: 20, height: 20,
            child: Checkbox(
              value: _rememberMe,
              onChanged: (v) => setState(() => _rememberMe = v ?? false),
              activeColor: AppColors.teal600,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          const Text('Remember me', style: TextStyle(fontSize: 13, color: AppColors.gray600)),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() { _mode = _Mode.forgotPassword; _error = null; }),
            child: const Text('Forgot Password?',
                style: TextStyle(fontSize: 13, color: AppColors.teal600,
                    fontWeight: FontWeight.w600)),
          ),
        ]),

        if (_error != null) _errorBox(_error!),
        const SizedBox(height: 22),

        // Login button — disabled until user types
        SizedBox(width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: _hasInput && !_loading ? _login : null,
            style: _btnStyle(),
            child: _loading
                ? _spinner()
                : const Text('Login', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 16),

        Center(child: _toggleText(
          "Don't have an account? ",
          'Register',
              () => setState(() { _mode = _Mode.register; _error = null; _formKey.currentState?.reset(); }),
        )),
      ]),
    );
  }

  // ── REGISTER FORM ─────────────────────────────────────────
  Widget _buildRegister() {
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title(Icons.person_add_outlined, 'Create Account',
            'Register to access the POS system'),
        const SizedBox(height: 24),

        _label('Full Name'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameCtrl,
          textInputAction: TextInputAction.next,
          decoration: _deco('Enter your full name', Icons.person_outline),
          validator: (v) => (v?.trim().isEmpty ?? true) ? 'Please enter your name' : null,
        ),
        const SizedBox(height: 14),

        _label('Email Address'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: _deco('Enter your email', Icons.email_outlined),
          validator: (v) {
            if (v?.trim().isEmpty ?? true) return 'Please enter email';
            if (!v!.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 14),

        _label('Mobile Number'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10)],
          decoration: _deco('10-digit mobile number', Icons.phone_outlined).copyWith(
            prefixText: '+91  ',
            prefixStyle: const TextStyle(fontSize: 14, color: AppColors.gray600,
                fontWeight: FontWeight.w500),
          ),
          validator: (v) {
            if (v?.trim().isEmpty ?? true) return 'Please enter mobile number';
            if (v!.trim().length != 10) return 'Enter a valid 10-digit number';
            return null;
          },
        ),
        const SizedBox(height: 14),

        _label('Create Password'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passCtrl,
          obscureText: _obscureP,
          textInputAction: TextInputAction.next,
          decoration: _deco('Min. 6 characters', Icons.lock_outline).copyWith(
            suffixIcon: _eyeBtn(_obscureP, () =>
                setState(() => _obscureP = !_obscureP)),
          ),
          validator: (v) {
            if (v?.isEmpty ?? true) return 'Please create a password';
            if (v!.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 14),

        _label('Confirm Password'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _confirmCtrl,
          obscureText: _obscureC,
          textInputAction: TextInputAction.done,
          decoration: _deco('Re-enter password', Icons.lock_outline).copyWith(
            suffixIcon: _eyeBtn(_obscureC, () =>
                setState(() => _obscureC = !_obscureC)),
          ),
          validator: (v) {
            if (v?.isEmpty ?? true) return 'Please confirm your password';
            if (v != _passCtrl.text) return 'Passwords do not match';
            return null;
          },
        ),

        if (_error != null) _errorBox(_error!),
        const SizedBox(height: 22),

        SizedBox(width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : _register,
            style: _btnStyle(),
            child: _loading
                ? _spinner()
                : const Text('Create Account & Send OTP',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 16),

        Center(child: _toggleText(
          'Already have an account? ', 'Login',
              () => setState(() { _mode = _Mode.login; _error = null; _formKey.currentState?.reset(); }),
        )),
      ]),
    );
  }

  // ── OTP VERIFY ───────────────────────────────────────────
  Widget _buildOtpVerify() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title(Icons.sms_outlined, 'Verify Mobile',
          'Enter the 6-digit OTP sent to +91 ${_phoneCtrl.text}'),
      const SizedBox(height: 24),

      _label('OTP Code'),
      const SizedBox(height: 6),
      TextField(
        controller: _otpCtrl,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
            letterSpacing: 12),
        decoration: _deco('', Icons.pin_outlined).copyWith(
          counterText: '',
          hintText: '------',
          hintStyle: const TextStyle(fontSize: 24, letterSpacing: 12,
              color: AppColors.gray300),
        ),
      ),

      if (_error != null) _errorBox(_error!),
      const SizedBox(height: 22),

      SizedBox(width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: _loading ? null : _verifyOtp,
          style: _btnStyle(),
          child: _loading ? _spinner()
              : const Text('Verify & Complete Registration',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 14),

      Center(child: TextButton(
        onPressed: _loading ? null : _sendOtp,
        child: const Text('Resend OTP',
            style: TextStyle(color: AppColors.teal600, fontWeight: FontWeight.w600)),
      )),
    ]);
  }

  // ── FORGOT PASSWORD ───────────────────────────────────────
  Widget _buildForgotPassword() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title(Icons.lock_reset_outlined, 'Reset Password',
          'Enter your email to receive a password reset link'),
      const SizedBox(height: 24),

      _label('Email Address'),
      const SizedBox(height: 6),
      TextField(
        controller: _resetCtrl,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _sendResetEmail(),
        decoration: _deco('Enter your registered email', Icons.email_outlined),
      ),

      if (_error != null) _errorBox(_error!),
      const SizedBox(height: 22),

      SizedBox(width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: _loading ? null : _sendResetEmail,
          style: _btnStyle(),
          child: _loading ? _spinner()
              : const Text('Send Reset Link',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 14),

      Center(child: _toggleText('Remember your password? ', 'Back to Login',
            () => setState(() { _mode = _Mode.login; _error = null; }),
      )),
    ]);
  }

  // ── Shared UI helpers ─────────────────────────────────────
  Widget _title(IconData icon, String title, String sub) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Icon(icon, size: 18, color: AppColors.gray400),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 4),
      Text(sub, style: const TextStyle(fontSize: 13, color: AppColors.gray400)),
    ],
  );

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.gray700));

  Widget _errorBox(String msg) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.red50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.red100)),
      child: Row(children: [
        const Icon(Icons.error_outline, size: 16, color: AppColors.red500),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: const TextStyle(fontSize: 13,
            color: AppColors.red700, fontWeight: FontWeight.w500))),
      ]),
    ),
  );

  Widget _toggleText(String prefix, String action, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: RichText(text: TextSpan(
          style: const TextStyle(fontSize: 13, color: AppColors.gray500),
          children: [
            TextSpan(text: prefix),
            TextSpan(text: action, style: const TextStyle(
                color: AppColors.teal600, fontWeight: FontWeight.w700)),
          ],
        )),
      );

  Widget _eyeBtn(bool obscure, VoidCallback onTap) => IconButton(
    icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 18, color: AppColors.gray400),
    onPressed: onTap,
  );

  Widget _spinner() => const SizedBox(width: 22, height: 22,
      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white));

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
    backgroundColor: AppColors.teal600,
    foregroundColor: AppColors.white,
    disabledBackgroundColor: AppColors.gray200,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 0,
  );

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