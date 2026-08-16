import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

/// ─────────────────────────────────────────────────────────────
///  EMAIL SERVICE  –  lib/services/email_service.dart
///  Sends OTP and welcome emails via Gmail SMTP
///
///  Setup: Gmail account mein App Password banao:
///  Google Account → Security → 2-Step Verification → App Passwords
///  App name: "Shree Sarees POS" → Generate → Copy password
/// ─────────────────────────────────────────────────────────────
class EmailService {
  // Apna Gmail aur App Password yahan daalo
  static const _senderEmail    = 'noreply.posmail@gmail.com';   // ← change karo
  static const _appPassword    = 'eimi lsnz zuku xmzh';    // ← Gmail App Password
  static const _senderName     = 'Shree Sarees POSo';

  // ── Send OTP email ────────────────────────────────────────
  static Future<bool> sendOtpEmail({
    required String toEmail,
    required String otp,
    required String userName,
  }) async {
    try {
      final smtpServer = gmail(_senderEmail, _appPassword);
      final message = Message()
        ..from     = Address(_senderEmail, _senderName)
        ..recipients.add(toEmail)
        ..subject  = 'Your OTP for Shree Sarees POS Registration'
        ..html     = _otpEmailTemplate(userName, otp);

      await send(message, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Send Welcome email ────────────────────────────────────
  static Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String userName,
  }) async {
    try {
      final smtpServer = gmail(_senderEmail, _appPassword);
      final message = Message()
        ..from     = Address(_senderEmail, _senderName)
        ..recipients.add(toEmail)
        ..subject  = 'Welcome to Shree Sarees POS!'
        ..html     = _welcomeEmailTemplate(userName);

      await send(message, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── OTP Email Template ────────────────────────────────────
  static String _otpEmailTemplate(String name, String otp) => '''
<!DOCTYPE html>
<html>
<body style="font-family: Arial, sans-serif; background: #f4f4f4; padding: 20px;">
  <div style="max-width: 480px; margin: auto; background: white;
              border-radius: 12px; overflow: hidden;
              box-shadow: 0 4px 20px rgba(0,0,0,0.1);">

    <!-- Header -->
    <div style="background: #0D9488; padding: 28px; text-align: center;">
      <h1 style="color: white; margin: 0; font-size: 22px; letter-spacing: 1px;">
        SHREE SAREES POS
      </h1>
      <p style="color: #99f6e4; margin: 6px 0 0; font-size: 13px;">
        Point of Sale System
      </p>
    </div>

    <!-- Body -->
    <div style="padding: 32px 28px;">
      <p style="font-size: 15px; color: #374151;">Hi <strong>$name</strong>,</p>
      <p style="font-size: 14px; color: #6B7280; line-height: 1.6;">
        Thank you for registering with Shree Sarees POS.
        Use the OTP below to complete your account setup.
      </p>

      <!-- OTP Box -->
      <div style="background: #F0FDFA; border: 2px solid #0D9488;
                  border-radius: 10px; padding: 24px; text-align: center;
                  margin: 24px 0;">
        <p style="margin: 0 0 8px; font-size: 13px; color: #6B7280;">
          Your One-Time Password
        </p>
        <h2 style="margin: 0; font-size: 42px; font-weight: 900;
                   letter-spacing: 10px; color: #0D9488;">
          $otp
        </h2>
        <p style="margin: 10px 0 0; font-size: 12px; color: #9CA3AF;">
          Valid for 10 minutes only
        </p>
      </div>

      <p style="font-size: 13px; color: #9CA3AF; line-height: 1.6;">
        If you did not request this OTP, please ignore this email.
        Do not share this OTP with anyone.
      </p>
    </div>

    <!-- Footer -->
    <div style="background: #F9FAFB; padding: 16px 28px;
                border-top: 1px solid #E5E7EB; text-align: center;">
      <p style="margin: 0; font-size: 12px; color: #9CA3AF;">
        &copy; 2026 Shree Sarees POS. All rights reserved.
      </p>
    </div>
  </div>
</body>
</html>
''';

  // ── Welcome Email Template ────────────────────────────────
  static String _welcomeEmailTemplate(String name) => '''
<!DOCTYPE html>
<html>
<body style="font-family: Arial, sans-serif; background: #f4f4f4; padding: 20px;">
  <div style="max-width: 480px; margin: auto; background: white;
              border-radius: 12px; overflow: hidden;
              box-shadow: 0 4px 20px rgba(0,0,0,0.1);">

    <div style="background: #0D9488; padding: 28px; text-align: center;">
      <h1 style="color: white; margin: 0; font-size: 22px; letter-spacing: 1px;">
        SHREE SAREES POS
      </h1>
    </div>

    <div style="padding: 32px 28px; text-align: center;">
      <div style="font-size: 56px; margin-bottom: 16px;">🎉</div>
      <h2 style="color: #0D9488; margin: 0 0 12px;">
        Congratulations, $name!
      </h2>
      <p style="font-size: 15px; color: #374151; line-height: 1.7;">
        Your account has been successfully created on
        <strong>Shree Sarees POS System</strong>.
      </p>
      <p style="font-size: 14px; color: #6B7280; line-height: 1.7;">
        You can now log in using your registered email address
        and password to access the POS system.
      </p>

      <div style="background: #F0FDFA; border-radius: 8px;
                  padding: 16px; margin: 20px 0; text-align: left;">
        <p style="margin: 0; font-size: 13px; color: #0F766E;">
          <strong>Account Details:</strong><br/>
          Name: $name<br/>
          Status: Active
        </p>
      </div>

      <p style="font-size: 13px; color: #9CA3AF;">
        If you did not create this account, please contact support immediately.
      </p>
    </div>

    <div style="background: #F9FAFB; padding: 16px 28px;
                border-top: 1px solid #E5E7EB; text-align: center;">
      <p style="margin: 0; font-size: 12px; color: #9CA3AF;">
        &copy; 2026 Shree Sarees POS. All rights reserved.
      </p>
    </div>
  </div>
</body>
</html>
''';
}