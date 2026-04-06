import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
<<<<<<< HEAD
import 'package:flutter/foundation.dart';
=======
import 'package:flutter/services.dart' show rootBundle;
>>>>>>> df388ed70c9c6c011ad0cfb29d2acd17f5106ae9

/// Main Supabase client singleton
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  /// Get the singleton instance
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Get the Supabase client
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call SupabaseService.initialize() first');
    }
    return _client!;
  }

  /// Initialize Supabase
  static Future<void> initialize() async {
    try {
<<<<<<< HEAD
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('⚠️ Could not load .env file: $e');
      // Continue with default values for development
=======
      // Try to load from assets first (works on all platforms)
      String envContent = await rootBundle.loadString('.env');
      // Parse the env file manually
      final lines = envContent.split('\n');
      for (String line in lines) {
        if (line.isNotEmpty && !line.startsWith('#')) {
          final parts = line.split('=');
          if (parts.length == 2) {
            dotenv.env[parts[0].trim()] = parts[1].trim();
          }
        }
      }
    } catch (e) {
      print('⚠️ Warning: Could not load .env from assets: $e');
      try {
        // Fall back to dotenv loading from file system
        await dotenv.load(fileName: '.env');
      } catch (e2) {
        print('⚠️ Warning: Could not load .env file: $e2');
      }
>>>>>>> df388ed70c9c6c011ad0cfb29d2acd17f5106ae9
    }
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-anon-key-here';

<<<<<<< HEAD
    if (supabaseUrl == 'https://your-project.supabase.co' || supabaseAnonKey == 'your-anon-key-here') {
      debugPrint('❌ Supabase credentials not configured. Please update your .env file with your Supabase project details.');
      debugPrint('📝 Copy .env.example to .env and add your credentials from https://app.supabase.com');
      throw Exception('Supabase credentials not configured. Please update .env file with your project details.');
=======
    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Supabase credentials not found in .env file. Please ensure SUPABASE_URL and SUPABASE_ANON_KEY are set.');
>>>>>>> df388ed70c9c6c011ad0cfb29d2acd17f5106ae9
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true, // Set to false in production
      );

      _client = Supabase.instance.client;
      debugPrint('✅ Supabase initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Supabase: $e');
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _client?.auth.currentUser != null;

  /// Get current user
  User? get currentUser => _client?.auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _client?.auth.currentUser?.id;
}
