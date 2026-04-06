/// Bookmark types
enum BookmarkType {
  affirmation,
  message,
  journal;

  String get value {
    switch (this) {
      case BookmarkType.affirmation:
        return 'affirmation';
      case BookmarkType.message:
        return 'message';
      case BookmarkType.journal:
        return 'journal';
    }
  }

  static BookmarkType fromString(String value) {
    switch (value) {
      case 'affirmation':
        return BookmarkType.affirmation;
      case 'message':
        return BookmarkType.message;
      case 'journal':
        return BookmarkType.journal;
      default:
        return BookmarkType.message;
    }
  }
}

/// Bookmark model for saving affirmations, messages, and journal entries
class Bookmark {
  final String id;
  final String userId;
  final BookmarkType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bookmark({
    required this.id,
    required this.userId,
    required this.type,
    required this.payload,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create from Supabase JSON
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: BookmarkType.fromString(json['type'] as String),
      payload: json['payload_json'] as Map<String, dynamic>,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.value,
      'payload_json': payload,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Helper to get display title based on type
  String get displayTitle {
    switch (type) {
      case BookmarkType.affirmation:
        return payload['content'] as String? ?? 'Affirmation';
      case BookmarkType.message:
        return payload['content'] as String? ?? 'Message';
      case BookmarkType.journal:
        return payload['title'] as String? ?? 'Journal Entry';
    }
  }

  /// Helper to get display content
  String get displayContent {
    switch (type) {
      case BookmarkType.affirmation:
        return payload['content'] as String? ?? '';
      case BookmarkType.message:
        return payload['content'] as String? ?? '';
      case BookmarkType.journal:
        return payload['content'] as String? ?? '';
    }
  }

  /// Copy with modifications
  Bookmark copyWith({
    String? id,
    String? userId,
    BookmarkType? type,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Bookmark(id: $id, type: $type, title: $displayTitle)';
}
