import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Email service for sending verification codes and other emails
/// Currently configured to use Resend API
class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  static EmailService get instance => _instance;

  // Resend API configuration
  static const String _resendApiUrl = 'https://api.resend.com/emails';
  
  String? get _apiKey => dotenv.env['RESEND_API_KEY'];
  String? get _fromEmail => dotenv.env['EMAIL_FROM'] ?? 'onboarding@resend.dev';

  /// Send verification code email
  Future<bool> sendVerificationCode({
    required String toEmail,
    required String code,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      print('⚠️ RESEND_API_KEY not found in .env file');
      print('📧 Email would be sent to: $toEmail');
      print('🔐 Verification code: $code');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(_resendApiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': _fromEmail,
          'to': [toEmail],
          'subject': 'Verify your email - Mental Health App',
          'html': _buildVerificationEmailHtml(code),
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Verification email sent to $toEmail');
        return true;
      } else {
        print('❌ Failed to send email: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending email: $e');
      return false;
    }
  }

  /// Send welcome email after successful signup
  Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String userName,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      print('⚠️ RESEND_API_KEY not found - skipping welcome email');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(_resendApiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': _fromEmail,
          'to': [toEmail],
          'subject': 'Welcome to Mental Health App! 🌟',
          'html': _buildWelcomeEmailHtml(userName),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error sending welcome email: $e');
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail({
    required String toEmail,
    required String resetCode,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      print('⚠️ RESEND_API_KEY not found - skipping password reset email');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(_resendApiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': _fromEmail,
          'to': [toEmail],
          'subject': 'Reset your password - Mental Health App',
          'html': _buildPasswordResetEmailHtml(resetCode),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error sending password reset email: $e');
      return false;
    }
  }

  /// Build HTML template for verification email
  String _buildVerificationEmailHtml(String code) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Verify Your Email</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f3f3f3;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f3f3f3; padding: 40px 20px;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
          <!-- Header -->
          <tr>
            <td style="padding: 40px 40px 20px 40px; text-align: center;">
              <h1 style="margin: 0; color: #1a1a1a; font-size: 28px; font-weight: 600;">Verify Your Email</h1>
            </td>
          </tr>
          
          <!-- Body -->
          <tr>
            <td style="padding: 20px 40px;">
              <p style="margin: 0 0 20px 0; color: #4a4a4a; font-size: 16px; line-height: 1.6;">
                Thank you for signing up! Please use the verification code below to complete your registration:
              </p>
              
              <!-- Verification Code Box -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                <tr>
                  <td align="center" style="background-color: #f8f8f8; border-radius: 12px; padding: 30px;">
                    <div style="font-size: 42px; font-weight: 700; letter-spacing: 12px; color: #1a1a1a; font-family: 'Courier New', monospace;">
                      $code
                    </div>
                  </td>
                </tr>
              </table>
              
              <p style="margin: 20px 0 0 0; color: #4a4a4a; font-size: 14px; line-height: 1.6;">
                This code will expire in <strong>10 minutes</strong>. If you didn't request this code, please ignore this email.
              </p>
            </td>
          </tr>
          
          <!-- Footer -->
          <tr>
            <td style="padding: 30px 40px 40px 40px; text-align: center; border-top: 1px solid #e8e8e8;">
              <p style="margin: 0; color: #8a8a8a; font-size: 12px; line-height: 1.5;">
                Mental Health App - Your journey to wellness starts here
              </p>
              <p style="margin: 10px 0 0 0; color: #8a8a8a; font-size: 12px;">
                Need help? Contact support@mentalhealth.app
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';
  }

  /// Build HTML template for welcome email
  String _buildWelcomeEmailHtml(String userName) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Welcome!</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f3f3f3;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f3f3f3; padding: 40px 20px;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
          <tr>
            <td style="padding: 40px; text-align: center;">
              <h1 style="margin: 0 0 20px 0; color: #1a1a1a; font-size: 32px;">Welcome, $userName! 🌟</h1>
              <p style="margin: 0; color: #4a4a4a; font-size: 16px; line-height: 1.6;">
                Your account has been successfully created. We're excited to have you on your wellness journey!
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';
  }

  /// Build HTML template for password reset email
  String _buildPasswordResetEmailHtml(String code) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Your Password</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f3f3f3;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f3f3f3; padding: 40px 20px;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
          <tr>
            <td style="padding: 40px;">
              <h1 style="margin: 0 0 20px 0; color: #1a1a1a; font-size: 28px;">Reset Your Password</h1>
              <p style="margin: 0 0 20px 0; color: #4a4a4a; font-size: 16px; line-height: 1.6;">
                Use the code below to reset your password:
              </p>
              <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                <tr>
                  <td align="center" style="background-color: #f8f8f8; border-radius: 12px; padding: 30px;">
                    <div style="font-size: 42px; font-weight: 700; letter-spacing: 12px; color: #1a1a1a; font-family: 'Courier New', monospace;">
                      $code
                    </div>
                  </td>
                </tr>
              </table>
              <p style="margin: 20px 0 0 0; color: #4a4a4a; font-size: 14px;">
                This code expires in 10 minutes. If you didn't request this, please ignore this email.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';
  }
}
