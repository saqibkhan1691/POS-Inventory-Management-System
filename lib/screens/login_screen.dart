import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';
import '../services/otp_service.dart';
import '../services/email_service.dart';

enum _Mode { login, register, enterOtp, forgotPassword }

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth       = FirebaseAuth.instance;
  final _db         = FirebaseFirestore.instance;
  final _otpService = OtpService();

  final _loginFormKey    = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login controllers
  final _loginIdCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  // Register controllers
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _otpCtrl     = TextEditingController();
  final _resetCtrl   = TextEditingController();

  _Mode   _mode       = _Mode.login;
  bool    _loginLoading    = false;
  bool    _registerLoading = false;
  bool    _otpLoading      = false;
  bool    _obscureLogin    = true;
  bool    _obscureP        = true;
  bool    _obscureC        = true;
  bool    _rememberMe      = false;
  bool    _hasLoginInput   = false;

  // Field-level errors
  String? _loginError;
  String? _emailFieldError;
  String? _phoneFieldError;
  String? _registerGeneralError;
  String? _otpError;
  String? _forgotError;

  String? _pendingEmail;
  String? _pendingName;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
    _loginIdCtrl.addListener(_checkLoginInput);
    _loginPassCtrl.addListener(_checkLoginInput);
  }

  void _checkLoginInput() {
    final has = _loginIdCtrl.text.isNotEmpty && _loginPassCtrl.text.isNotEmpty;
    if (has != _hasLoginInput) setState(() => _hasLoginInput = has);
  }

  // Clear all register fields — called on back/mode change
  void _clearRegisterFields() {
    _nameCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
    _passCtrl.clear();
    _confirmCtrl.clear();
    _otpCtrl.clear();
    _emailFieldError   = null;
    _phoneFieldError   = null;
    _registerGeneralError = null;
    _otpError          = null;
    _pendingEmail      = null;
    _pendingName       = null;
    _registerFormKey.currentState?.reset();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final rem   = prefs.getBool('remember_me') ?? false;
    final saved = prefs.getString('saved_login') ?? '';
    if (rem && saved.isNotEmpty && mounted) {
      setState(() { _rememberMe = true; _loginIdCtrl.text = saved; });
    }
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_login', _loginIdCtrl.text.trim());
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('saved_login');
    }
  }

  @override
  void dispose() {
    _loginIdCtrl.dispose(); _loginPassCtrl.dispose();
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    _otpCtrl.dispose(); _resetCtrl.dispose();
    super.dispose();
  }

  // ── LOGIN ─────────────────────────────────────────────────
  Future<void> _login() async {
    if (!(_loginFormKey.currentState?.validate() ?? false)) return;
    setState(() { _loginLoading = true; _loginError = null; });
    try {
      String email = _loginIdCtrl.text.trim();

      // Mobile number se email lookup
      if (!email.contains('@')) {
        final q = await _db.collection('users')
            .where('phone', isEqualTo: email).limit(1).get();
        if (q.docs.isEmpty) {
          setState(() => _loginError = 'No account found with this mobile number.');
          return;
        }
        email = q.docs.first.data()['email'] as String;
      }

      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: _loginPassCtrl.text.trim());

      // Update last login
      await _db.collection('users').doc(cred.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      await _saveRememberMe();
      if (mounted) widget.onLoginSuccess();

    } on FirebaseAuthException catch (e) {
      setState(() => _loginError = _err(e.code));
    } finally {
      if (mounted) setState(() => _loginLoading = false);
    }
  }

  // ── REGISTER — validate + check duplicates + send OTP ────
  Future<void> _sendOtp() async {
    // Reset field errors
    setState(() {
      _emailFieldError      = null;
      _phoneFieldError      = null;
      _registerGeneralError = null;
    });

    if (!(_registerFormKey.currentState?.validate() ?? false)) return;

    setState(() => _registerLoading = true);

    try {
      final email = _emailCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();

      // Check email already registered — BEFORE sending OTP
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        setState(() => _emailFieldError =
        'This email is already registered. Please login.');
        return;
      }

      // Check phone uniqueness — BEFORE sending OTP
      if (await _otpService.isPhoneRegistered(phone)) {
        setState(() => _phoneFieldError =
        'This mobile number is already linked to another account.');
        return;
      }

      // Generate + send OTP
      final otp  = await _otpService.generateAndStoreOtp(email);
      final sent = await EmailService.sendOtpEmail(
        toEmail:  email,
        otp:      otp,
        userName: _nameCtrl.text.trim(),
      );

      if (!sent) {
        setState(() => _registerGeneralError =
        'Could not send OTP. Check internet connection.');
        return;
      }

      // Clear password fields for privacy before moving to OTP screen
      setState(() {
        _pendingEmail = email;
        _pendingName  = _nameCtrl.text.trim();
        _mode         = _Mode.enterOtp;
      });

    } on FirebaseAuthException catch (e) {
      setState(() => _registerGeneralError = _err(e.code));
    } finally {
      if (mounted) setState(() => _registerLoading = false);
    }
  }

  // ── VERIFY OTP + CREATE ACCOUNT ───────────────────────────
  Future<void> _verifyOtpAndCreate() async {
    final entered = _otpCtrl.text.trim();
    if (entered.length != 6) {
      setState(() => _otpError = 'Please enter the 6-digit OTP');
      return;
    }
    setState(() { _otpLoading = true; _otpError = null; });

    try {
      final result = await _otpService.verifyOtp(_pendingEmail!, entered);
      switch (result) {
        case OtpResult.invalid:
          setState(() => _otpError = 'Incorrect OTP. Please try again.');
          return;
        case OtpResult.expired:
          setState(() => _otpError = 'OTP expired. Please go back and request a new one.');
          return;
        case OtpResult.alreadyUsed:
          setState(() => _otpError = 'This OTP has already been used.');
          return;
        case OtpResult.notFound:
          setState(() => _otpError = 'OTP not found. Please request a new one.');
          return;
        case OtpResult.success:
          break;
      }

      // Create Firebase Auth account
      final cred = await _auth.createUserWithEmailAndPassword(
        email:    _pendingEmail!,
        password: _passCtrl.text.trim(),
      );
      await cred.user?.updateDisplayName(_pendingName!);

      // Save to Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid':       cred.user!.uid,
        'name':      _pendingName,
        'email':     _pendingEmail,
        'phone':     _phoneCtrl.text.trim(),
        'role':      'cashier',
        'isActive':  true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Welcome email (background)
      EmailService.sendWelcomeEmail(
        toEmail:  _pendingEmail!,
        userName: _pendingName!,
      );

      // Clear all fields
      _clearRegisterFields();

      if (mounted) {
        _showSnack('Account created! Welcome, $_pendingName!', AppColors.teal600);
        // Direct login — go to main screen
        widget.onLoginSuccess();
      }

    } on FirebaseAuthException catch (e) {
      setState(() => _otpError = _err(e.code));
    } finally {
      if (mounted) setState(() => _otpLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_pendingEmail == null) return;
    setState(() { _otpLoading = true; _otpError = null; });
    try {
      final otp = await _otpService.generateAndStoreOtp(_pendingEmail!);
      await EmailService.sendOtpEmail(
          toEmail: _pendingEmail!, otp: otp, userName: _pendingName ?? '');
      _showSnack('OTP resent to $_pendingEmail', AppColors.teal600);
    } finally {
      if (mounted) setState(() => _otpLoading = false);
    }
  }

  Future<void> _sendResetEmail() async {
    final email = _resetCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _forgotError = 'Please enter your email address');
      return;
    }
    setState(() { _otpLoading = true; _forgotError = null; });
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnack('Reset link sent to $email', AppColors.teal600);
      setState(() { _mode = _Mode.login; _forgotError = null; });
    } on FirebaseAuthException catch (e) {
      setState(() => _forgotError = _err(e.code));
    } finally {
      if (mounted) setState(() => _otpLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 3),
    ));
  }

  String _err(String code) {
    switch (code) {
      case 'user-not-found':         return 'No account found with this email.';
      case 'wrong-password':         return 'Incorrect password. Please try again.';
      case 'invalid-credential':     return 'Invalid email or password.';
      case 'invalid-email':          return 'Please enter a valid email address.';
      case 'email-already-in-use':   return 'This email is already registered. Please login.';
      case 'weak-password':          return 'Password must be at least 6 characters.';
      case 'too-many-requests':      return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'No internet connection.';
      default: return 'Something went wrong. Please try again.';
    }
  }

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
                  boxShadow: [BoxShadow(
                      color: AppColors.teal600.withOpacity(0.4),
                      blurRadius: 32, spreadRadius: 2)],
                ),
                child: const Icon(Icons.storefront_outlined,
                    color: AppColors.white, size: 34),
              ),
              const SizedBox(height: 18),
              const Text('SHREE SAREES', style: TextStyle(
                  color: AppColors.white, fontSize: 26,
                  fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              const SizedBox(height: 6),
              const Text('POS SYSTEM', style: TextStyle(
                  color: AppColors.slate400, fontSize: 11,
                  fontWeight: FontWeight.w600, letterSpacing: 2.5)),
              const SizedBox(height: 32),

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
                  Container(height: 4, decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppColors.teal600, AppColors.teal700]))),
                  Padding(
                      padding: const EdgeInsets.all(32),
                      child: _buildContent()),
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
      case _Mode.login:          return _buildLogin();
      case _Mode.register:       return _buildRegister();
      case _Mode.enterOtp:       return _buildEnterOtp();
      case _Mode.forgotPassword: return _buildForgotPassword();
    }
  }

  // ── LOGIN ─────────────────────────────────────────────────
  Widget _buildLogin() => Form(
    key: _loginFormKey,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title(Icons.lock_outline, 'Secure Login',
          'Sign in with email or mobile number'),
      const SizedBox(height: 24),

      _label('Email Address or Mobile Number'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _loginIdCtrl,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        decoration: _deco('Enter email or 10-digit mobile', Icons.person_outline),
        validator: (v) => (v?.trim().isEmpty ?? true)
            ? 'Please enter email or mobile number' : null,
      ),
      const SizedBox(height: 16),

      _label('Password'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _loginPassCtrl,
        obscureText: _obscureLogin,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) { if (_hasLoginInput && !_loginLoading) _login(); },
        decoration: _deco('Enter your password', Icons.lock_outline).copyWith(
          suffixIcon: _eyeBtn(_obscureLogin,
                  () => setState(() => _obscureLogin = !_obscureLogin)),
        ),
        validator: (v) => (v?.isEmpty ?? true) ? 'Please enter password' : null,
      ),
      const SizedBox(height: 14),

      Row(children: [
        SizedBox(width: 20, height: 20, child: Checkbox(
          value: _rememberMe,
          onChanged: (v) => setState(() => _rememberMe = v ?? false),
          activeColor: AppColors.teal600,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        )),
        const SizedBox(width: 8),
        const Text('Remember me',
            style: TextStyle(fontSize: 13, color: AppColors.gray600)),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() { _mode = _Mode.forgotPassword; _loginError = null; }),
          child: const Text('Forgot Password?', style: TextStyle(
              fontSize: 13, color: AppColors.teal600, fontWeight: FontWeight.w600)),
        ),
      ]),

      if (_loginError != null) _errorBox(_loginError!),
      const SizedBox(height: 22),

      SizedBox(width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: _hasLoginInput && !_loginLoading ? _login : null,
          style: _btnStyle(),
          child: _loginLoading ? _spinner()
              : const Text('Login', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 16),
      Center(child: _toggleText("Don't have an account? ", 'Register',
              () {
            _clearRegisterFields();
            setState(() { _mode = _Mode.register; _loginError = null; });
          })),
    ]),
  );

  // ── REGISTER ─────────────────────────────────────────────
  Widget _buildRegister() => Form(
    key: _registerFormKey,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title(Icons.person_add_outlined, 'Create Account', 'Fill details to register'),
      const SizedBox(height: 20),

      _label('Full Name'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _nameCtrl,
        textInputAction: TextInputAction.next,
        decoration: _deco('Enter your full name', Icons.person_outline),
        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Please enter your name' : null,
      ),
      const SizedBox(height: 12),

      _label('Email Address'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        // Clear email error on typing
        onChanged: (_) => setState(() => _emailFieldError = null),
        decoration: _deco('Enter your email', Icons.email_outlined).copyWith(
          errorText: _emailFieldError,
        ),
        validator: (v) {
          if (v?.trim().isEmpty ?? true) return 'Please enter email';
          if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(v!.trim()))
            return 'Enter a valid email address';
          return null;
        },
      ),
      const SizedBox(height: 12),

      _label('Mobile Number'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        onChanged: (_) => setState(() => _phoneFieldError = null),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: _deco('10-digit mobile number', Icons.phone_outlined).copyWith(
          prefixText: '+91  ',
          prefixStyle: const TextStyle(fontSize: 14,
              color: AppColors.gray600, fontWeight: FontWeight.w500),
          errorText: _phoneFieldError,
          helperText: _phoneFieldError == null ? 'One account per mobile number' : null,
          helperStyle: const TextStyle(fontSize: 11, color: AppColors.gray400),
        ),
        validator: (v) {
          if (v?.trim().isEmpty ?? true) return 'Please enter mobile number';
          if (v!.trim().length != 10) return 'Enter valid 10-digit number';
          return null;
        },
      ),
      const SizedBox(height: 12),

      _label('Create Password'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _passCtrl,
        obscureText: _obscureP,
        textInputAction: TextInputAction.next,
        decoration: _deco('Min. 6 characters', Icons.lock_outline).copyWith(
          suffixIcon: _eyeBtn(_obscureP, () => setState(() => _obscureP = !_obscureP)),
        ),
        validator: (v) {
          if (v?.isEmpty ?? true) return 'Please create a password';
          if (v!.length < 6) return 'Password must be at least 6 characters';
          return null;
        },
      ),
      const SizedBox(height: 12),

      _label('Confirm Password'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _confirmCtrl,
        obscureText: _obscureC,
        textInputAction: TextInputAction.done,
        decoration: _deco('Re-enter password', Icons.lock_outline).copyWith(
          suffixIcon: _eyeBtn(_obscureC, () => setState(() => _obscureC = !_obscureC)),
        ),
        validator: (v) {
          if (v?.isEmpty ?? true) return 'Please confirm your password';
          if (v != _passCtrl.text) return 'Passwords do not match';
          return null;
        },
      ),
      const SizedBox(height: 12),

      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.teal50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.teal100)),
        child: const Row(children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.teal600),
          SizedBox(width: 8),
          Expanded(child: Text('An OTP will be sent to your email to verify your account.',
              style: TextStyle(fontSize: 12, color: AppColors.teal700))),
        ]),
      ),

      if (_registerGeneralError != null) _errorBox(_registerGeneralError!),
      const SizedBox(height: 20),

      SizedBox(width: double.infinity, height: 50,
        child: ElevatedButton.icon(
          onPressed: _registerLoading ? null : _sendOtp,
          icon: _registerLoading
              ? const SizedBox() : const Icon(Icons.send_outlined, size: 18),
          label: _registerLoading ? _spinner()
              : const Text('Get OTP', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700)),
          style: _btnStyle(),
        ),
      ),
      const SizedBox(height: 16),
      Center(child: _toggleText('Already have an account? ', 'Login',
              () {
            _clearRegisterFields();
            setState(() { _mode = _Mode.login; });
          })),
    ]),
  );

  // ── OTP ENTRY ─────────────────────────────────────────────
  Widget _buildEnterOtp() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _title(Icons.mark_email_read_outlined, 'Enter OTP',
          'We sent a 6-digit OTP to $_pendingEmail'),
      const SizedBox(height: 24),

      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.teal50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.teal100)),
        child: Row(children: [
          const Icon(Icons.email_outlined, color: AppColors.teal600, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('OTP sent to:', style: TextStyle(
                fontSize: 12, color: AppColors.teal600)),
            Text(_pendingEmail ?? '', style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.teal700)),
          ])),
        ]),
      ),
      const SizedBox(height: 20),

      _label('Enter 6-Digit OTP'),
      const SizedBox(height: 8),
      TextField(
        controller: _otpCtrl,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        onChanged: (_) => setState(() => _otpError = null),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
            letterSpacing: 14, color: AppColors.teal600),
        decoration: InputDecoration(
          counterText: '',
          hintText: '------',
          hintStyle: const TextStyle(fontSize: 28, letterSpacing: 14,
              color: AppColors.gray200),
          filled: true, fillColor: AppColors.gray50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.gray200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.gray200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.teal600, width: 2)),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
      const SizedBox(height: 6),
      const Text('OTP is valid for 10 minutes',
          style: TextStyle(fontSize: 11, color: AppColors.gray400)),

      if (_otpError != null) _errorBox(_otpError!),
      const SizedBox(height: 22),

      SizedBox(width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: _otpLoading ? null : _verifyOtpAndCreate,
          style: _btnStyle(),
          child: _otpLoading ? _spinner()
              : const Text('Confirm & Create Account',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 12),

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        TextButton.icon(
          onPressed: _otpLoading ? null : _resendOtp,
          icon: const Icon(Icons.refresh, size: 16, color: AppColors.teal600),
          label: const Text('Resend OTP', style: TextStyle(
              color: AppColors.teal600, fontWeight: FontWeight.w600)),
        ),
        TextButton(
          // Go back to register — clear all fields for privacy
          onPressed: () {
            _clearRegisterFields();
            setState(() => _mode = _Mode.register);
          },
          child: const Text('Change Details',
              style: TextStyle(color: AppColors.gray400)),
        ),
      ]),
    ],
  );

  // ── FORGOT PASSWORD ───────────────────────────────────────
  Widget _buildForgotPassword() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _title(Icons.lock_reset_outlined, 'Reset Password',
          'Enter your registered email'),
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
      if (_forgotError != null) _errorBox(_forgotError!),
      const SizedBox(height: 22),
      SizedBox(width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: _otpLoading ? null : _sendResetEmail,
          style: _btnStyle(),
          child: _otpLoading ? _spinner()
              : const Text('Send Reset Link', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 14),
      Center(child: _toggleText('Remember password? ', 'Back to Login',
              () => setState(() { _mode = _Mode.login; _forgotError = null; _resetCtrl.clear(); }))),
    ],
  );

  // ── Shared helpers ────────────────────────────────────────
  Widget _title(IconData icon, String title, String sub) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: AppColors.gray400),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 4),
        Text(sub, style: const TextStyle(fontSize: 13, color: AppColors.gray400)),
      ]);

  Widget _label(String t) => Text(t, style: const TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700));

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
        Expanded(child: Text(msg, style: const TextStyle(
            fontSize: 13, color: AppColors.red700, fontWeight: FontWeight.w500))),
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
    filled: true, fillColor: AppColors.gray50,
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