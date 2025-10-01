import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Service for handling email verification using Supabase's built-in OTP system
/// 
/// This service uses Supabase Auth's native OTP functionality which:
/// - Generates secure 6-digit codes automatically
/// - Sends emails using your configured email template
/// - Handles expiration (default 1 hour)
/// - Provides built-in rate limiting
class EmailVerificationService {
  static final EmailVerificationService _instance = EmailVerificationService._internal();
  factory EmailVerificationService() => _instance;
  EmailVerificationService._internal();

  static EmailVerificationService get instance => _instance;

  get _supabase => SupabaseService.client;

  /// Send OTP verification code to email using Supabase Auth
  /// 
  /// Supabase will:
  /// 1. Generate a secure 6-digit code
  /// 2. Send it using your custom email template ({{ .Token }})
  /// 3. Handle expiration automatically (default 1 hour)
  /// 4. Rate limit requests to prevent abuse
  Future<void> sendVerificationCode(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email.toLowerCase(),
        emailRedirectTo: null, // No redirect needed for OTP
      );
      
      print('✅ OTP sent to $email via Supabase');
      print('📧 Check your email for the 6-digit code');
    } catch (e) {
      print('❌ Failed to send OTP: $e');
      throw Exception('Failed to send verification code: $e');
    }
  }

  /// Verify the OTP code entered by the user
  /// 
  /// This will:
  /// 1. Validate the code with Supabase Auth
  /// 2. Create/sign in the user if code is valid
  /// 3. Return true if successful, false otherwise
  Future<bool> verifyCode(String email, String code) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        token: code,
        email: email.toLowerCase(),
      );
      
      if (response.user != null) {
        print('✅ OTP verified successfully for ${response.user!.email}');
        return true;
      } else {
        print('❌ OTP verification failed - invalid code');
        return false;
      }
    } catch (e) {
      print('❌ Error verifying OTP: $e');
      return false;
    }
  }

  /// Resend verification code (same as sending new OTP)
  /// 
  /// Note: Supabase has built-in rate limiting to prevent abuse
  /// Users may need to wait 60 seconds between requests
  Future<void> resendVerificationCode(String email) async {
    try {
      await sendVerificationCode(email);
    } catch (e) {
      // If rate limited, provide helpful message
      if (e.toString().contains('rate limit')) {
        throw Exception('Please wait before requesting another code');
      }
      rethrow;
    }
  }
}
