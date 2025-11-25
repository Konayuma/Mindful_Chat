import '../models/bookmark.dart';
import '../models/affirmation.dart';
import 'supabase_service.dart';
import 'supabase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for managing bookmarks/favorites
class BookmarkService {
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal();

  List<Bookmark>? _cachedBookmarks;
  static const String _localBookmarksKey = 'local_bookmarks';

  /// Get all bookmarks for current user
  Future<List<Bookmark>> getAllBookmarks() async {
    try {
      final userId = SupabaseAuthService.instance.currentUserId;
      if (userId == null) {
        return await _getLocalBookmarks();
      }

      final supabase = SupabaseService.client;
      final response = await supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _cachedBookmarks = (response as List)
          .map((json) => Bookmark.fromJson(json))
          .toList();

      return _cachedBookmarks!;
    } catch (e) {
      print('❌ Error fetching bookmarks: $e');
      return await _getLocalBookmarks();
    }
  }

  /// Get bookmarks by type
  Future<List<Bookmark>> getBookmarksByType(BookmarkType type) async {
    final bookmarks = await getAllBookmarks();
    return bookmarks.where((b) => b.type == type).toList();
  }

  /// Create a bookmark
  Future<Bookmark?> createBookmark({
    required BookmarkType type,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final userId = SupabaseAuthService.instance.currentUserId;
      
      if (userId == null) {
        return await _createLocalBookmark(type: type, payload: payload);
      }

      final supabase = SupabaseService.client;
      final now = DateTime.now().toIso8601String();
      
      final response = await supabase.from('bookmarks').insert({
        'user_id': userId,
        'type': type.value,
        'payload_json': payload,
        'created_at': now,
        'updated_at': now,
      }).select().single();

      final bookmark = Bookmark.fromJson(response);
      
      // Update cache
      if (_cachedBookmarks != null) {
        _cachedBookmarks!.insert(0, bookmark);
      }

      print('✅ Bookmark created: ${bookmark.displayTitle}');
      return bookmark;
    } catch (e) {
      print('❌ Error creating bookmark: $e');
      return await _createLocalBookmark(type: type, payload: payload);
    }
  }

  /// Create bookmark from affirmation
  Future<Bookmark?> bookmarkAffirmation(Affirmation affirmation) async {
    return await createBookmark(
      type: BookmarkType.affirmation,
      payload: {
        'id': affirmation.id,
        'content': affirmation.content,
        'author': affirmation.author,
        'category': affirmation.category,
        'tags': affirmation.tags,
      },
    );
  }

  /// Create bookmark from chat message
  Future<Bookmark?> bookmarkMessage({
    required String messageId,
    required String content,
    String? conversationId,
  }) async {
    return await createBookmark(
      type: BookmarkType.message,
      payload: {
        'id': messageId,
        'content': content,
        'conversation_id': conversationId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Create bookmark from journal entry
  Future<Bookmark?> bookmarkJournal({
    required String journalId,
    required String title,
    required String content,
    List<String>? tags,
  }) async {
    return await createBookmark(
      type: BookmarkType.journal,
      payload: {
        'id': journalId,
        'title': title,
        'content': content,
        'tags': tags ?? [],
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Delete a bookmark
  Future<bool> deleteBookmark(String bookmarkId) async {
    try {
      final userId = SupabaseAuthService.instance.currentUserId;
      
      if (userId == null) {
        return await _deleteLocalBookmark(bookmarkId);
      }

      final supabase = SupabaseService.client;
      await supabase
          .from('bookmarks')
          .delete()
          .eq('id', bookmarkId)
          .eq('user_id', userId);

      // Update cache
      if (_cachedBookmarks != null) {
        _cachedBookmarks!.removeWhere((b) => b.id == bookmarkId);
      }

      print('✅ Bookmark deleted: $bookmarkId');
      return true;
    } catch (e) {
      print('❌ Error deleting bookmark: $e');
      return await _deleteLocalBookmark(bookmarkId);
    }
  }

  /// Check if item is bookmarked
  Future<bool> isBookmarked({
    required BookmarkType type,
    required String itemId,
  }) async {
    final bookmarks = await getBookmarksByType(type);
    return bookmarks.any((b) => b.payload['id'] == itemId);
  }

  /// Find bookmark by item ID
  Future<Bookmark?> findBookmark({
    required BookmarkType type,
    required String itemId,
  }) async {
    final bookmarks = await getBookmarksByType(type);
    try {
      return bookmarks.firstWhere((b) => b.payload['id'] == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Toggle bookmark (add if not exists, remove if exists)
  Future<bool> toggleBookmark({
    required BookmarkType type,
    required String itemId,
    required Map<String, dynamic> payload,
  }) async {
    final existing = await findBookmark(type: type, itemId: itemId);
    
    if (existing != null) {
      await deleteBookmark(existing.id);
      return false; // Removed
    } else {
      await createBookmark(type: type, payload: payload);
      return true; // Added
    }
  }

  /// Search bookmarks
  Future<List<Bookmark>> searchBookmarks(String keyword) async {
    final bookmarks = await getAllBookmarks();
    final lowerKeyword = keyword.toLowerCase();
    
    return bookmarks.where((b) {
      return b.displayTitle.toLowerCase().contains(lowerKeyword) ||
          b.displayContent.toLowerCase().contains(lowerKeyword);
    }).toList();
  }

  /// Clear cache
  void clearCache() {
    _cachedBookmarks = null;
  }

  // ============================================
  // LOCAL STORAGE METHODS (OFFLINE SUPPORT)
  // ============================================

  Future<List<Bookmark>> _getLocalBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_localBookmarksKey);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Bookmark.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error loading local bookmarks: $e');
      return [];
    }
  }

  Future<Bookmark?> _createLocalBookmark({
    required BookmarkType type,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final bookmark = Bookmark(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'local',
        type: type,
        payload: payload,
      );

      final bookmarks = await _getLocalBookmarks();
      bookmarks.insert(0, bookmark);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _localBookmarksKey,
        json.encode(bookmarks.map((b) => b.toJson()).toList()),
      );

      return bookmark;
    } catch (e) {
      print('❌ Error creating local bookmark: $e');
      return null;
    }
  }

  Future<bool> _deleteLocalBookmark(String bookmarkId) async {
    try {
      final bookmarks = await _getLocalBookmarks();
      bookmarks.removeWhere((b) => b.id == bookmarkId);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _localBookmarksKey,
        json.encode(bookmarks.map((b) => b.toJson()).toList()),
      );

      return true;
    } catch (e) {
      print('❌ Error deleting local bookmark: $e');
      return false;
    }
  }
}
