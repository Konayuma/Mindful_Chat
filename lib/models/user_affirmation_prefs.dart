/// User's affirmation preferences for notifications and scheduling
class UserAffirmationPrefs {
  final String id;
  final String userId;
  final bool notificationEnabled;
  final String notificationTime; // HH:mm format
  final DateTime? lastShownDate;
  final String? lastAffirmationId;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserAffirmationPrefs({
    required this.id,
    required this.userId,
    this.notificationEnabled = false,
    this.notificationTime = '09:00',
    this.lastShownDate,
    this.lastAffirmationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create from Supabase JSON
  factory UserAffirmationPrefs.fromJson(Map<String, dynamic> json) {
    return UserAffirmationPrefs(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      notificationEnabled: json['notification_enabled'] as bool? ?? false,
      notificationTime: json['notification_time'] as String? ?? '09:00',
      lastShownDate: json['last_shown_date'] != null
          ? DateTime.parse(json['last_shown_date'] as String)
          : null,
      lastAffirmationId: json['last_affirmation_id'] as String?,
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
      'notification_enabled': notificationEnabled,
      'notification_time': notificationTime,
      'last_shown_date': lastShownDate?.toIso8601String().split('T')[0],
      'last_affirmation_id': lastAffirmationId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with modifications
  UserAffirmationPrefs copyWith({
    String? id,
    String? userId,
    bool? notificationEnabled,
    String? notificationTime,
    DateTime? lastShownDate,
    String? lastAffirmationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserAffirmationPrefs(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      lastShownDate: lastShownDate ?? this.lastShownDate,
      lastAffirmationId: lastAffirmationId ?? this.lastAffirmationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'UserAffirmationPrefs(userId: $userId, notificationEnabled: $notificationEnabled, time: $notificationTime)';
}
