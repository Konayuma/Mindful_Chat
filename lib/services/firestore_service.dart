import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Singleton pattern
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _conversationsCollection => _firestore.collection('conversations');
  CollectionReference get _messagesCollection => _firestore.collection('messages');

  // ==================== USER OPERATIONS ====================

  /// Create a new user profile in Firestore
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _usersCollection.doc(userId).set({
        'userId': userId,
        'email': email,
        'displayName': displayName ?? email.split('@')[0],
        'photoUrl': photoUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'settings': {
          'notifications': true,
          'theme': 'light',
        },
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final updates = <String, dynamic>{
        'lastActive': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (settings != null) updates['settings'] = settings;

      await _usersCollection.doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Update user's last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to update last active: $e');
    }
  }

  // ==================== CONVERSATION OPERATIONS ====================

  /// Create a new conversation
  Future<String> createConversation({
    required String userId,
    String title = 'New Conversation',
  }) async {
    try {
      final docRef = await _conversationsCollection.add({
        'userId': userId,
        'title': title,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'messageCount': 0,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  /// Get all conversations for a user
  Stream<List<Map<String, dynamic>>> getUserConversations(String userId) {
    return _conversationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get a specific conversation
  Future<Map<String, dynamic>?> getConversation(String conversationId) async {
    try {
      final doc = await _conversationsCollection.doc(conversationId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get conversation: $e');
    }
  }

  /// Update conversation title
  Future<void> updateConversationTitle({
    required String conversationId,
    required String title,
  }) async {
    try {
      await _conversationsCollection.doc(conversationId).update({
        'title': title,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update conversation title: $e');
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete all messages in the conversation
      final messages = await _messagesCollection
          .where('conversationId', isEqualTo: conversationId)
          .get();

      for (var doc in messages.docs) {
        await doc.reference.delete();
      }

      // Delete the conversation
      await _conversationsCollection.doc(conversationId).delete();
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }

  // ==================== MESSAGE OPERATIONS ====================

  /// Add a message to a conversation
  Future<String> addMessage({
    required String conversationId,
    required String userId,
    required String content,
    required String role, // 'user' or 'assistant'
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final docRef = await _messagesCollection.add({
        'conversationId': conversationId,
        'userId': userId,
        'content': content,
        'role': role,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': metadata ?? {},
      });

      // Update conversation's updatedAt and messageCount
      await _conversationsCollection.doc(conversationId).update({
        'updatedAt': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add message: $e');
    }
  }

  /// Get messages for a conversation
  Stream<List<Map<String, dynamic>>> getConversationMessages(
    String conversationId,
  ) {
    return _messagesCollection
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _messagesCollection.doc(messageId).delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // ==================== MOOD TRACKING OPERATIONS ====================

  /// Save mood entry
  Future<void> saveMoodEntry({
    required String userId,
    required String mood,
    required int rating, // 1-5
    String? note,
    List<String>? activities,
  }) async {
    try {
      await _firestore.collection('mood_entries').add({
        'userId': userId,
        'mood': mood,
        'rating': rating,
        'note': note ?? '',
        'activities': activities ?? [],
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save mood entry: $e');
    }
  }

  /// Get mood entries for a user
  Stream<List<Map<String, dynamic>>> getMoodEntries(String userId) {
    return _firestore
        .collection('mood_entries')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ==================== JOURNAL OPERATIONS ====================

  /// Save journal entry
  Future<void> saveJournalEntry({
    required String userId,
    required String title,
    required String content,
    List<String>? tags,
  }) async {
    try {
      await _firestore.collection('journal_entries').add({
        'userId': userId,
        'title': title,
        'content': content,
        'tags': tags ?? [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save journal entry: $e');
    }
  }

  /// Get journal entries for a user
  Stream<List<Map<String, dynamic>>> getJournalEntries(String userId) {
    return _firestore
        .collection('journal_entries')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Update journal entry
  Future<void> updateJournalEntry({
    required String entryId,
    String? title,
    String? content,
    List<String>? tags,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (tags != null) updates['tags'] = tags;

      await _firestore.collection('journal_entries').doc(entryId).update(updates);
    } catch (e) {
      throw Exception('Failed to update journal entry: $e');
    }
  }

  /// Delete journal entry
  Future<void> deleteJournalEntry(String entryId) async {
    try {
      await _firestore.collection('journal_entries').doc(entryId).delete();
    } catch (e) {
      throw Exception('Failed to delete journal entry: $e');
    }
  }
}
