import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_preferences.dart';

/// Service for managing user preferences and personalization
class UserPreferencesService {
  static final UserPreferencesService _instance = UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();

  static const String _prefsKey = 'user_preferences';
  UserPreferences? _cachedPreferences;

  /// Get current user's preferences
  Future<UserPreferences> getUserPreferences() async {
    if (_cachedPreferences != null) {
      return _cachedPreferences!;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return _getLocalPreferences();
      }

      // Try to fetch from Supabase
      final response = await Supabase.instance.client
          .from('user_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        _cachedPreferences = UserPreferences.fromJson(response);
        await _saveLocalPreferences(_cachedPreferences!);
        return _cachedPreferences!;
      }

      // If no remote preferences, try local
      return await _getLocalPreferences();
    } catch (e) {
      print('Error fetching user preferences: $e');
      return await _getLocalPreferences();
    }
  }

  /// Save user preferences
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final updatedPreferences = preferences.copyWith(
        userId: user?.id,
        updatedAt: DateTime.now(),
      );

      if (user != null) {
        // Save to Supabase
        await Supabase.instance.client.from('user_preferences').upsert({
          'user_id': user.id,
          'mental_health_goals': updatedPreferences.mentalHealthGoals,
          'preferred_reminder_time': updatedPreferences.preferredReminderTime,
          'communication_style': updatedPreferences.communicationStyle,
          'onboarding_completed': updatedPreferences.onboardingCompleted,
          'updated_at': updatedPreferences.updatedAt?.toIso8601String(),
        });
      }

      // Always save locally as backup
      await _saveLocalPreferences(updatedPreferences);
      _cachedPreferences = updatedPreferences;
    } catch (e) {
      print('Error saving user preferences: $e');
      // Still save locally even if remote fails
      await _saveLocalPreferences(preferences);
      _cachedPreferences = preferences;
    }
  }

  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    final prefs = await getUserPreferences();
    return prefs.onboardingCompleted;
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final currentPrefs = await getUserPreferences();
    final updatedPrefs = currentPrefs.copyWith(
      onboardingCompleted: true,
      updatedAt: DateTime.now(),
    );
    await saveUserPreferences(updatedPrefs);
  }

  /// Get preferences from local storage
  Future<UserPreferences> _getLocalPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString(_prefsKey);
      
      if (prefsJson != null) {
        final Map<String, dynamic> decoded = Map<String, dynamic>.from(
          Uri.splitQueryString(prefsJson).map(
            (key, value) => MapEntry(key, _decodeValue(value)),
          ),
        );
        return UserPreferences.fromJson(decoded);
      }
    } catch (e) {
      print('Error loading local preferences: $e');
    }

    return UserPreferences();
  }

  /// Save preferences to local storage
  Future<void> _saveLocalPreferences(UserPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = preferences.toJson();
      final encoded = json.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(_encodeValue(e.value))}')
          .join('&');
      await prefs.setString(_prefsKey, encoded);
    } catch (e) {
      print('Error saving local preferences: $e');
    }
  }

  /// Encode value for storage
  String _encodeValue(dynamic value) {
    if (value == null) return '';
    if (value is List) return value.join(',');
    return value.toString();
  }

  /// Decode value from storage
  dynamic _decodeValue(String value) {
    if (value.isEmpty) return null;
    if (value.contains(',')) return value.split(',');
    if (value == 'true') return true;
    if (value == 'false') return false;
    return value;
  }

  /// Clear cached preferences
  void clearCache() {
    _cachedPreferences = null;
  }
}
