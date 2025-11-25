import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Authentication service using Supabase Auth
class SupabaseAuthService {
  static SupabaseAuthService? _instance;
  
  SupabaseAuthService._();
  
  /// Get singleton instance
  static SupabaseAuthService get instance {
    _instance ??= SupabaseAuthService._();
    return _instance!;
  }

  /// Get Supabase auth client
  GoTrueClient get _auth => SupabaseService.client.auth;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user id
  String? get currentUserId => currentUser?.id;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      if (response.user == null) {
        throw Exception('Sign up failed: No user returned');
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Update user password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception('Password update failed: No user returned');
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  /// Update user email
  Future<UserResponse> updateEmail(String newEmail) async {
    try {
      final response = await _auth.updateUser(
        UserAttributes(email: newEmail),
      );

      if (response.user == null) {
        throw Exception('Email update failed: No user returned');
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Email update failed: $e');
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Handle auth exceptions and return user-friendly messages
  String _handleAuthException(AuthException error) {
    switch (error.statusCode) {
      case '400':
        if (error.message.contains('Invalid login credentials')) {
          return 'Invalid email or password';
        }
        return 'Invalid request. Please check your input.';
      case '422':
        if (error.message.contains('User already registered')) {
          return 'An account with this email already exists';
        }
        return 'Invalid email or password format';
      case '429':
        return 'Too many requests. Please try again later.';
      case '500':
        return 'Server error. Please try again later.';
      default:
        return error.message;
    }
  }
}
