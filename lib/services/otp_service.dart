import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ─────────────────────────────────────────────────────────────
///  OTP SERVICE  –  lib/services/otp_service.dart
/// ─────────────────────────────────────────────────────────────
class OtpService {
  final _db = FirebaseFirestore.instance;

  String _generateOtp() {
    final rng = Random.secure();
    return (100000 + rng.nextInt(900000)).toString();
  }

  // Generate OTP + store in Firestore with 10 min expiry
  Future<String> generateAndStoreOtp(String email) async {
    final otp    = _generateOtp();
    final expiry = DateTime.now().add(const Duration(minutes: 10));
    await _db.collection('otp_verification').doc(email).set({
      'otp':       otp,
      'email':     email,
      'expiresAt': expiry.toIso8601String(),
      'used':      false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return otp;
  }

  // Verify entered OTP
  Future<OtpResult> verifyOtp(String email, String enteredOtp) async {
    final doc = await _db.collection('otp_verification').doc(email).get();
    if (!doc.exists)                    return OtpResult.notFound;
    final data   = doc.data()!;
    final stored = data['otp']       as String;
    final used   = data['used']      as bool;
    final expiry = DateTime.parse(data['expiresAt'] as String);
    if (used)                           return OtpResult.alreadyUsed;
    if (DateTime.now().isAfter(expiry)) return OtpResult.expired;
    if (stored != enteredOtp)           return OtpResult.invalid;
    await _db.collection('otp_verification').doc(email)
        .update({'used': true});
    return OtpResult.success;
  }

  // Check phone uniqueness
  Future<bool> isPhoneRegistered(String phone) async {
    final q = await _db.collection('users')
        .where('phone', isEqualTo: phone).limit(1).get();
    return q.docs.isNotEmpty;
  }
}

enum OtpResult { success, invalid, expired, notFound, alreadyUsed }