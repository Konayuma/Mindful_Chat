import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Database service for all Supabase database operations
class SupabaseDatabaseService {
  static SupabaseDatabaseService? _instance;

  SupabaseDatabaseService._();

  /// Get singleton instance
  static SupabaseDatabaseService get instance {
    _instance ??= SupabaseDatabaseService._();
    return _instance!;
  }

  /// Get Supabase client
  SupabaseClient get _client => SupabaseService.client;

  // ============================================
  // USER PROFILE OPERATIONS
  // ============================================

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (displayName != null) updates['display_name'] = displayName;
      if (preferences != null) updates['preferences'] = preferences;

      await _client
          .from('users')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Create user profile (call after sign up)
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    try {
      await _client.from('users').insert({
        'id': userId,
        'email': email,
        'display_name': displayName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'last_active': DateTime.now().toIso8601String(),
        'preferences': {},
      });
    } catch (e) {
      // If user already exists, ignore the error
      if (!e.toString().contains('duplicate key')) {
        throw Exception('Failed to create user profile: $e');
      }
    }
  }

  /// Ensure user profile exists (upsert)
  Future<void> ensureUserProfile({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    try {
      await _client.from('users').upsert({
        'id': userId,
        'email': email,
        'display_name': displayName,
        'updated_at': DateTime.now().toIso8601String(),
        'last_active': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    } catch (e) {
      throw Exception('Failed to ensure user profile: $e');
    }
  }

  /// Update user's last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await _client
          .from('users')
          .update({'last_active': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      // Silently fail - not critical
      print('Failed to update last active: $e');
    }
  }

  // ============================================
  // CONVERSATION OPERATIONS
  // ============================================

  /// Get all conversations for a user (stream for real-time updates)
  Stream<List<Map<String, dynamic>>> getUserConversations(String userId) {
    return _client
        .from('conversations')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
  }

  /// Get a single conversation
  Future<Map<String, dynamic>?> getConversation(String conversationId) async {
    try {
      final response = await _client
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      throw Exception('Failed to get conversation: $e');
    }
  }

  /// Create a new conversation
  Future<Map<String, dynamic>> createConversation({
    required String userId,
    String? title,
  }) async {
    try {
      final response = await _client
          .from('conversations')
          .insert({
            'user_id': userId,
            'title': title ?? 'New Conversation',
          })
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  /// Update conversation
  Future<void> updateConversation({
    required String conversationId,
    String? title,
    bool? isArchived,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updates['title'] = title;
      if (isArchived != null) updates['is_archived'] = isArchived;

      await _client
          .from('conversations')
          .update(updates)
          .eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to update conversation: $e');
    }
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _client
          .from('conversations')
          .delete()
          .eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }

  // ============================================
  // MESSAGE OPERATIONS
  // ============================================

  /// Get messages for a conversation (stream for real-time updates)
  Stream<List<Map<String, dynamic>>> getConversationMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('timestamp', ascending: true);
  }

  /// Add a message to a conversation
  Future<Map<String, dynamic>> addMessage({
    required String conversationId,
    required String content,
    required bool isUserMessage,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _client
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'content': content,
            'is_user_message': isUserMessage,
            'metadata': metadata ?? {},
          })
          .select()
          .single();

      // Update conversation's updated_at timestamp
      await updateConversation(conversationId: conversationId);
      
      return response;
    } catch (e) {
      throw Exception('Failed to add message: $e');
    }
  }

  // ============================================
  // MOOD ENTRY OPERATIONS
  // ============================================

  /// Get mood entries for a user
  Future<List<Map<String, dynamic>>> getMoodEntries({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      dynamic query = _client
          .from('mood_entries')
          .select()
          .eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('timestamp', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('timestamp', endDate.toIso8601String());
      }

      query = query.order('timestamp', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get mood entries: $e');
    }
  }

  /// Save a mood entry
  Future<Map<String, dynamic>> saveMoodEntry({
    required String userId,
    required int moodLevel,
    String? notes,
    List<String>? tags,
  }) async {
    try {
      final response = await _client
          .from('mood_entries')
          .insert({
            'user_id': userId,
            'mood_level': moodLevel,
            'notes': notes,
            'tags': tags ?? [],
          })
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to save mood entry: $e');
    }
  }

  /// Delete mood entry
  Future<void> deleteMoodEntry(String entryId) async {
    try {
      await _client
          .from('mood_entries')
          .delete()
          .eq('id', entryId);
    } catch (e) {
      throw Exception('Failed to delete mood entry: $e');
    }
  }

  // ============================================
  // JOURNAL ENTRY OPERATIONS
  // ============================================

  /// Get journal entries for a user
  Future<List<Map<String, dynamic>>> getJournalEntries({
    required String userId,
    int? limit,
  }) async {
    try {
      var query = _client
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get journal entries: $e');
    }
  }

  /// Save a journal entry
  Future<Map<String, dynamic>> saveJournalEntry({
    required String userId,
    required String title,
    required String content,
    List<String>? tags,
    bool isPrivate = true,
  }) async {
    try {
      final response = await _client
          .from('journal_entries')
          .insert({
            'user_id': userId,
            'title': title,
            'content': content,
            'tags': tags ?? [],
            'is_private': isPrivate,
          })
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to save journal entry: $e');
    }
  }

  /// Update journal entry
  Future<void> updateJournalEntry({
    required String entryId,
    String? title,
    String? content,
    List<String>? tags,
    bool? isPrivate,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (tags != null) updates['tags'] = tags;
      if (isPrivate != null) updates['is_private'] = isPrivate;

      await _client
          .from('journal_entries')
          .update(updates)
          .eq('id', entryId);
    } catch (e) {
      throw Exception('Failed to update journal entry: $e');
    }
  }

  /// Delete journal entry
  Future<void> deleteJournalEntry(String entryId) async {
    try {
      await _client
          .from('journal_entries')
          .delete()
          .eq('id', entryId);
    } catch (e) {
      throw Exception('Failed to delete journal entry: $e');
    }
  }
}
