import 'dart:math';
import 'package:flutter/foundation.dart';

class OtpService {
  static final OtpService _instance = OtpService._internal();
  factory OtpService() => _instance;
  OtpService._internal();

  // Store OTP codes temporarily (in production, use a secure backend)
  final Map<String, OtpData> _otpStorage = {};

  // Generate a 6-digit OTP
  String generateOtp() {
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    return otp;
  }

  // Store OTP for an email
  void storeOtp(String email, String otp) {
    _otpStorage[email.toLowerCase()] = OtpData(
      otp: otp,
      timestamp: DateTime.now(),
      attempts: 0,
    );
    debugPrint('OTP stored for $email: $otp');
  }

  // Verify OTP
  bool verifyOtp(String email, String enteredOtp) {
    final emailKey = email.toLowerCase();
    final otpData = _otpStorage[emailKey];

    if (otpData == null) {
      debugPrint('No OTP found for $email');
      return false;
    }

    // Check if OTP is expired (10 minutes)
    final now = DateTime.now();
    final difference = now.difference(otpData.timestamp);
    if (difference.inMinutes > 10) {
      _otpStorage.remove(emailKey);
      debugPrint('OTP expired for $email');
      return false;
    }

    // Check attempts (max 3 attempts)
    if (otpData.attempts >= 3) {
      _otpStorage.remove(emailKey);
      debugPrint('Too many attempts for $email');
      return false;
    }

    // Increment attempts
    otpData.attempts++;

    // Verify OTP
    if (otpData.otp == enteredOtp) {
      _otpStorage.remove(emailKey); // Remove after successful verification
      debugPrint('OTP verified successfully for $email');
      return true;
    } else {
      debugPrint('Invalid OTP for $email. Attempts: ${otpData.attempts}');
      return false;
    }
  }

  // Check if OTP exists for email
  bool hasValidOtp(String email) {
    final emailKey = email.toLowerCase();
    final otpData = _otpStorage[emailKey];

    if (otpData == null) return false;

    // Check if expired
    final now = DateTime.now();
    final difference = now.difference(otpData.timestamp);
    if (difference.inMinutes > 10) {
      _otpStorage.remove(emailKey);
      return false;
    }

    return true;
  }

  // Get remaining time for OTP
  int getRemainingTime(String email) {
    final emailKey = email.toLowerCase();
    final otpData = _otpStorage[emailKey];

    if (otpData == null) return 0;

    final now = DateTime.now();
    final difference = now.difference(otpData.timestamp);
    final remainingMinutes = 10 - difference.inMinutes;

    return remainingMinutes > 0 ? remainingMinutes : 0;
  }

  // Clear OTP for email
  void clearOtp(String email) {
    _otpStorage.remove(email.toLowerCase());
  }

  // Send OTP via email (simulation)
  Future<bool> sendOtpEmail(String email, String otp) async {
    try {
      // In a real app, you would integrate with an email service like:
      // - SendGrid
      // - AWS SES
      // - Mailgun
      // - Firebase Functions with Nodemailer

      // For demo purposes, we'll simulate sending email
      await Future.delayed(const Duration(seconds: 1));

      // Simulate email content (this would be sent via email service)
      final emailSubject = 'Password Reset Verification Code';
      final emailBody =
          '''
Dear User,

You have requested to reset your password. Please use the following 6-digit verification code:

$otp

This code will expire in 10 minutes for security reasons.

If you did not request this password reset, please ignore this email.

Best regards,
Your App Team
      ''';

      // Log email details (in production, this would actually send email)
      debugPrint('📧 EMAIL SENT TO: $email');
      debugPrint('📧 SUBJECT: $emailSubject');
      debugPrint('📧 BODY: $emailBody');
      debugPrint('✅ Email delivery simulated successfully');

      return true;
    } catch (e) {
      debugPrint('Failed to send OTP email: $e');
      return false;
    }
  }
}

class OtpData {
  final String otp;
  final DateTime timestamp;
  int attempts;

  OtpData({required this.otp, required this.timestamp, this.attempts = 0});
}
