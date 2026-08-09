import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';
import '../services/otp_service.dart';
import '../services/email_service.dart';

/// ─────────────────────────────────────────────────────────────
///  LOGIN SCREEN v4  –  lib/screens/login_screen.dart
///
///  Login:  Email/Mobile + Password → Direct login (no OTP)
///  Register: Name + Email + Mobile + Password + Confirm →
///            Get OTP → OTP sent to email → Enter OTP →
///            Account created + Welcome email sent
/// ─────────────────────────────────────────────────────────────
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
  final _formKey    = GlobalKey<FormState>();

  // Controllers
  final _loginIdCtrl = TextEditingController(); // email or mobile for login
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _otpCtrl     = TextEditingController();
  final _resetCtrl   = TextEditingController();

  _Mode   _mode      = _Mode.login;
  bool    _loading   = false;
  bool    _obscureP  = true;
  bool    _obscureC  = true;
  bool    _rememberMe= false;
  bool    _hasInput  = false;
  String? _error;
  String? _pendingEmail; // email waiting for OTP
  String? _pendingName;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
    _loginIdCtrl.addListener(_checkInput);
    _passCtrl.addListener(_checkInput);
  }

  void _checkInput() {
    final has = _loginIdCtrl.text.isNotEmpty && _passCtrl.text.isNotEmpty;
    if (has != _hasInput) setState(() => _hasInput = has);
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
    for (final c in [_loginIdCtrl, _nameCtrl, _emailCtrl,
      _phoneCtrl, _passCtrl, _confirmCtrl, _otpCtrl, _resetCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── LOGIN — email or mobile + password ────────────────────
  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    try {
      String email = _loginIdCtrl.text.trim();

      // If mobile number entered, look up email from Firestore
      if (!email.contains('@')) {
        final q = await _db.collection('users')
            .where('phone', isEqualTo: email).limit(1).get();
        if (q.docs.isEmpty) {
          setState(() => _error = 'No account found with this mobile number.');
          return;
        }
        email = q.docs.first.data()['email'] as String;
      }

      await _auth.signInWithEmailAndPassword(
        email:    email,
        password: _passCtrl.text.trim(),
      );

      // Update last login
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _db.collection('users').doc(uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      await _saveRememberMe();
      if (mounted) widget.onLoginSuccess();

    } on FirebaseAuthException catch (e) {
      setState(() => _error = _err(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── REGISTER Step 1 — validate + send OTP ─────────────────
  Future<void> _sendOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    try {
      final phone = _phoneCtrl.text.trim();
      final email = _emailCtrl.text.trim();

      // Check phone uniqueness
      if (await _otpService.isPhoneRegistered(phone)) {
        setState(() => _error =
        'This mobile number is already registered with a different account.');
        return;
      }

      // Generate OTP and store in Firestore
      final otp = await _otpService.generateAndStoreOtp(email);

      // Send OTP email
      final sent = await EmailService.sendOtpEmail(
        toEmail:  email,
        otp:      otp,
        userName: _nameCtrl.text.trim(),
      );

      if (!sent) {
        setState(() => _error =
        'Could not send OTP email. Check your internet connection.');
        return;
      }

      setState(() {
        _pendingEmail = email;
        _pendingName  = _nameCtrl.text.trim();
        _mode         = _Mode.enterOtp;
      });

    } on FirebaseAuthException catch (e) {
      setState(() => _error = _err(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── REGISTER Step 2 — verify OTP + create account ─────────
  Future<void> _verifyOtpAndCreate() async {
    final entered = _otpCtrl.text.trim();
    if (entered.length != 6) {
      setState(() => _error = 'Please enter the 6-digit OTP');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      // Verify OTP
      final result = await _otpService.verifyOtp(_pendingEmail!, entered);

      switch (result) {
        case OtpResult.invalid:
          setState(() => _error = 'Incorrect OTP. Please try again.');
          return;
        case OtpResult.expired:
          setState(() => _error = 'OTP has expired. Please request a new one.');
          return;
        case OtpResult.alreadyUsed:
          setState(() => _error = 'This OTP has already been used.');
          return;
        case OtpResult.notFound:
          setState(() => _error = 'OTP not found. Please request a new one.');
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

      // Save user to Firestore
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

      // Send welcome email (don't await — let it run in background)
      EmailService.sendWelcomeEmail(
        toEmail:  _pendingEmail!,
        userName: _pendingName!,
      );

      if (mounted) {
        _showSnack('Account created successfully! Welcome, $_pendingName!',
            AppColors.teal600);
        // Auto login
        widget.onLoginSuccess();
      }

    } on FirebaseAuthException catch (e) {
      setState(() => _error = _err(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── RESEND OTP ────────────────────────────────────────────
  Future<void> _resendOtp() async {
    if (_pendingEmail == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final otp = await _otpService.generateAndStoreOtp(_pendingEmail!);
      await EmailService.sendOtpEmail(
        toEmail:  _pendingEmail!,
        otp:      otp,
        userName: _pendingName ?? '',
      );
      _showSnack('OTP resent to $_pendingEmail', AppColors.teal600);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── FORGOT PASSWORD ───────────────────────────────────────
  Future<void> _sendResetEmail() async {
    final email = _resetCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnack('Password reset link sent to $email', AppColors.teal600);
      setState(() => _mode = _Mode.login);
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
      duration: const Duration(seconds: 3),
    ));
  }

  String _err(String code) {
    switch (code) {
      case 'user-not-found':          return 'No account found with this email.';
      case 'wrong-password':          return 'Incorrect password. Please try again.';
      case 'invalid-credential':      return 'Invalid email or password.';
      case 'invalid-email':           return 'Please enter a valid email address.';
      case 'email-already-in-use':    return 'This email is already registered. Please login.';
      case 'weak-password':           return 'Password must be at least 6 characters.';
      case 'too-many-requests':       return 'Too many attempts. Please try again later.';
      case 'network-request-failed':  return 'No internet connection. Please check and try again.';
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

              // Card
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
                  Padding(padding: const EdgeInsets.all(32),
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

  // ── LOGIN FORM ────────────────────────────────────────────
  Widget _buildLogin() => Form(
    key: _formKey,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title(Icons.lock_outline, 'Secure Login', 'Sign in with email or mobile number'),
      const SizedBox(height: 24),

      _label('Email Address or Mobile Number'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _loginIdCtrl,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        decoration: _deco('Enter email or 10-digit mobile', Icons.person_outline),
        validator: (v) {
          if (v?.trim().isEmpty ?? true) return 'Please enter email or mobile number';
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
        onFieldSubmitted: (_) { if (_hasInput && !_loading) _login(); },
        decoration: _deco('Enter your password', Icons.lock_outline).copyWith(
          suffixIcon: _eyeBtn(_obscureP,
                  () => setState(() => _obscureP = !_obscureP)),
        ),
        validator: (v) =>
        (v?.isEmpty ?? true) ? 'Please enter password' : null,
      ),
      const SizedBox(height: 14),

      // Remember me + Forgot password
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
          onTap: () => setState(() { _mode = _Mode.forgotPassword; _error = null; }),
          child: const Text('Forgot Password?', style: TextStyle(
              fontSize: 13, color: AppColors.teal600,
              fontWeight: FontWeight.w600)),
        ),
      ]),

      if (_error != null) _errorBox(_error!),
      const SizedBox(height: 22),

      SizedBox(width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: _hasInput && !_loading ? _login : null,
          style: _btnStyle(),
          child: _loading ? _spinner()
              : const Text('Login', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 16),
      Center(child: _toggleText("Don't have an account? ", 'Register',
              () => setState(() {
            _mode = _Mode.register; _error = null;
            _formKey.currentState?.reset();
          }))),
    ]),
  );

  // ── REGISTER FORM ─────────────────────────────────────────
  Widget _buildRegister() => Form(
    key: _formKey,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title(Icons.person_add_outlined, 'Create Account',
          'Fill details to register'),
      const SizedBox(height: 20),

      _label('Full Name'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _nameCtrl,
        textInputAction: TextInputAction.next,
        decoration: _deco('Enter your full name', Icons.person_outline),
        validator: (v) =>
        (v?.trim().isEmpty ?? true) ? 'Please enter your name' : null,
      ),
      const SizedBox(height: 12),

      _label('Email Address'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        decoration: _deco('Enter your email', Icons.email_outlined),
        validator: (v) {
          if (v?.trim().isEmpty ?? true) return 'Please enter email';
          if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$')
              .hasMatch(v!.trim())) return 'Enter a valid email address';
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
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: _deco('10-digit mobile number', Icons.phone_outlined).copyWith(
          prefixText: '+91  ',
          prefixStyle: const TextStyle(fontSize: 14,
              color: AppColors.gray600, fontWeight: FontWeight.w500),
          helperText: 'One account per mobile number',
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
          suffixIcon: _eyeBtn(_obscureP,
                  () => setState(() => _obscureP = !_obscureP)),
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
          suffixIcon: _eyeBtn(_obscureC,
                  () => setState(() => _obscureC = !_obscureC)),
        ),
        validator: (v) {
          if (v?.isEmpty ?? true) return 'Please confirm your password';
          if (v != _passCtrl.text) return 'Passwords do not match';
          return null;
        },
      ),
      const SizedBox(height: 12),

      // Info note
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.teal50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.teal100),
        ),
        child: const Row(children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.teal600),
          SizedBox(width: 8),
          Expanded(child: Text(
            'An OTP will be sent to your email to verify your account.',
            style: TextStyle(fontSize: 12, color: AppColors.teal700),
          )),
        ]),
      ),

      if (_error != null) _errorBox(_error!),
      const SizedBox(height: 20),

      SizedBox(width: double.infinity, height: 50,
        child: ElevatedButton.icon(
          onPressed: _loading ? null : _sendOtp,
          icon: _loading ? const SizedBox()
              : const Icon(Icons.send_outlined, size: 18),
          label: _loading ? _spinner()
              : const Text('Get OTP', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700)),
          style: _btnStyle(),
        ),
      ),
      const SizedBox(height: 16),
      Center(child: _toggleText('Already have an account? ', 'Login',
              () => setState(() {
            _mode = _Mode.login; _error = null;
            _formKey.currentState?.reset();
          }))),
    ]),
  );

  // ── OTP ENTRY ─────────────────────────────────────────────
  Widget _buildEnterOtp() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _title(Icons.mark_email_read_outlined, 'Enter OTP',
          'We sent a 6-digit OTP to $_pendingEmail'),
      const SizedBox(height: 24),

      // OTP sent info box
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.teal50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.teal100),
        ),
        child: Row(children: [
          const Icon(Icons.email_outlined, color: AppColors.teal600, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('OTP sent to:', style: TextStyle(
                  fontSize: 12, color: AppColors.teal600)),
              Text(_pendingEmail ?? '', style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppColors.teal700)),
            ],
          )),
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
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
            letterSpacing: 14, color: AppColors.teal600),
        decoration: InputDecoration(
          counterText: '',
          hintText: '------',
          hintStyle: const TextStyle(fontSize: 28, letterSpacing: 14,
              color: AppColors.gray200),
          filled: true,
          fillColor: AppColors.gray50,
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

      if (_error != null) _errorBox(_error!),
      const SizedBox(height: 22),

      SizedBox(width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: _loading ? null : _verifyOtpAndCreate,
          style: _btnStyle(),
          child: _loading ? _spinner()
              : const Text('Verify OTP & Create Account',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 12),

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        TextButton.icon(
          onPressed: _loading ? null : _resendOtp,
          icon: const Icon(Icons.refresh, size: 16, color: AppColors.teal600),
          label: const Text('Resend OTP',
              style: TextStyle(color: AppColors.teal600,
                  fontWeight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: () => setState(() {
            _mode = _Mode.register; _error = null; _otpCtrl.clear();
          }),
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
        decoration: _deco('Enter your email', Icons.email_outlined),
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
      Center(child: _toggleText('Remember password? ', 'Back to Login',
              () => setState(() { _mode = _Mode.login; _error = null; }))),
    ],
  );

  // ── Shared helpers ────────────────────────────────────────
  Widget _title(IconData icon, String title, String sub) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: AppColors.gray400),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w700)),
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
            fontSize: 13, color: AppColors.red700,
            fontWeight: FontWeight.w500))),
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
    icon: Icon(obscure
        ? Icons.visibility_off_outlined
        : Icons.visibility_outlined,
        size: 18, color: AppColors.gray400),
    onPressed: onTap,
  );

  Widget _spinner() => const SizedBox(width: 22, height: 22,
      child: CircularProgressIndicator(strokeWidth: 2,
          color: AppColors.white));

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