/// Affirmation model for daily mental health affirmations
class Affirmation {
  final String id;
  final String content;
  final String? author;
  final String category;
  final List<String> tags;
  final DateTime createdAt;
  final bool isActive;

  Affirmation({
    required this.id,
    required this.content,
    this.author,
    this.category = 'general',
    this.tags = const [],
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create from Supabase JSON
  factory Affirmation.fromJson(Map<String, dynamic> json) {
    return Affirmation(
      id: json['id'] as String,
      content: json['content'] as String,
      author: json['author'] as String?,
      category: json['category'] as String? ?? 'general',
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author,
      'category': category,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Copy with modifications
  Affirmation copyWith({
    String? id,
    String? content,
    String? author,
    String? category,
    List<String>? tags,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Affirmation(
      id: id ?? this.id,
      content: content ?? this.content,
      author: author ?? this.author,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() => 'Affirmation(id: $id, content: ${content.substring(0, 30)}..., category: $category)';
}
