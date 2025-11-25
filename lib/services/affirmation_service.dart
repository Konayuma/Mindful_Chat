import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/affirmation.dart';
import 'supabase_service.dart';

/// Service for managing daily affirmations
class AffirmationService {
  static final AffirmationService _instance = AffirmationService._internal();
  factory AffirmationService() => _instance;
  AffirmationService._internal();

  List<Affirmation>? _cachedAffirmations;
  Affirmation? _dailyAffirmation;
  final Random _random = Random();

  static const String _lastShownDateKey = 'last_affirmation_date';
  static const String _lastAffirmationIdKey = 'last_affirmation_id';

  /// Load affirmations from local JSON file
  Future<List<Affirmation>> _loadLocalAffirmations() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/affirmations.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList
          .map((json) => Affirmation(
                id: json['content'].hashCode.toString(),
                content: json['content'] as String,
                author: json['author'] as String?,
                category: json['category'] as String? ?? 'general',
                tags: List<String>.from(json['tags'] ?? []),
              ))
          .toList();
    } catch (e) {
      print('❌ Error loading local affirmations: $e');
      return [];
    }
  }

  /// Get all affirmations (local + remote)
  Future<List<Affirmation>> getAllAffirmations() async {
    if (_cachedAffirmations != null && _cachedAffirmations!.isNotEmpty) {
      return _cachedAffirmations!;
    }

    // Load local affirmations first
    final localAffirmations = await _loadLocalAffirmations();
    _cachedAffirmations = localAffirmations;

    // Try to fetch remote affirmations in background
    _fetchRemoteAffirmations().then((remoteAffirmations) {
      if (remoteAffirmations.isNotEmpty) {
        _cachedAffirmations = [...localAffirmations, ...remoteAffirmations];
      }
    }).catchError((e) {
      print('⚠️ Could not fetch remote affirmations: $e');
    });

    return _cachedAffirmations!;
  }

  /// Fetch affirmations from Supabase
  Future<List<Affirmation>> _fetchRemoteAffirmations() async {
    try {
      final supabase = SupabaseService.client;
      final response = await supabase
          .from('affirmations')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Affirmation.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching remote affirmations: $e');
      return [];
    }
  }

  /// Get daily affirmation (changes once per day)
  Future<Affirmation> getDailyAffirmation() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastShownDate = prefs.getString(_lastShownDateKey);

    // Check if we already have today's affirmation
    if (lastShownDate == today && _dailyAffirmation != null) {
      return _dailyAffirmation!;
    }

    // Get all affirmations
    final affirmations = await getAllAffirmations();
    
    if (affirmations.isEmpty) {
      throw Exception('No affirmations available');
    }

    // Select a random affirmation different from yesterday
    final lastAffirmationId = prefs.getString(_lastAffirmationIdKey);
    Affirmation selectedAffirmation;
    
    if (affirmations.length == 1) {
      selectedAffirmation = affirmations[0];
    } else {
      // Try to get a different affirmation than yesterday
      do {
        selectedAffirmation = affirmations[_random.nextInt(affirmations.length)];
      } while (selectedAffirmation.id == lastAffirmationId && affirmations.length > 1);
    }

    // Cache the selection
    _dailyAffirmation = selectedAffirmation;
    await prefs.setString(_lastShownDateKey, today);
    await prefs.setString(_lastAffirmationIdKey, selectedAffirmation.id);

    return selectedAffirmation;
  }

  /// Get random affirmation (always random)
  Future<Affirmation> getRandomAffirmation() async {
    final affirmations = await getAllAffirmations();
    
    if (affirmations.isEmpty) {
      throw Exception('No affirmations available');
    }

    return affirmations[_random.nextInt(affirmations.length)];
  }

  /// Get affirmations by category
  Future<List<Affirmation>> getAffirmationsByCategory(String category) async {
    final affirmations = await getAllAffirmations();
    return affirmations
        .where((a) => a.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Search affirmations by keyword
  Future<List<Affirmation>> searchAffirmations(String keyword) async {
    final affirmations = await getAllAffirmations();
    final lowerKeyword = keyword.toLowerCase();
    
    return affirmations.where((a) {
      return a.content.toLowerCase().contains(lowerKeyword) ||
          a.category.toLowerCase().contains(lowerKeyword) ||
          a.tags.any((tag) => tag.toLowerCase().contains(lowerKeyword));
    }).toList();
  }

  /// Get affirmations by tags
  Future<List<Affirmation>> getAffirmationsByTags(List<String> tags) async {
    final affirmations = await getAllAffirmations();
    return affirmations.where((a) {
      return tags.any((tag) => a.tags.contains(tag.toLowerCase()));
    }).toList();
  }

  /// Clear cache (for testing)
  void clearCache() {
    _cachedAffirmations = null;
    _dailyAffirmation = null;
  }

  /// Get all available categories
  Future<List<String>> getAllCategories() async {
    final affirmations = await getAllAffirmations();
    final categories = affirmations.map((a) => a.category).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Get all available tags
  Future<List<String>> getAllTags() async {
    final affirmations = await getAllAffirmations();
    final tags = <String>{};
    for (final affirmation in affirmations) {
      tags.addAll(affirmation.tags);
    }
    final tagList = tags.toList();
    tagList.sort();
    return tagList;
  }
}
