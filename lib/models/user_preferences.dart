import 'package:flutter/material.dart';

/// User preferences model for personalization
class UserPreferences {
  final String? userId;
  final List<String> mentalHealthGoals;
  final String? preferredReminderTime;
  final String communicationStyle;
  final bool onboardingCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserPreferences({
    this.userId,
    this.mentalHealthGoals = const [],
    this.preferredReminderTime,
    this.communicationStyle = 'supportive',
    this.onboardingCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['user_id'] as String?,
      mentalHealthGoals: json['mental_health_goals'] != null
          ? List<String>.from(json['mental_health_goals'] as List)
          : [],
      preferredReminderTime: json['preferred_reminder_time'] as String?,
      communicationStyle: json['communication_style'] as String? ?? 'supportive',
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'mental_health_goals': mentalHealthGoals,
      'preferred_reminder_time': preferredReminderTime,
      'communication_style': communicationStyle,
      'onboarding_completed': onboardingCompleted,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserPreferences copyWith({
    String? userId,
    List<String>? mentalHealthGoals,
    String? preferredReminderTime,
    String? communicationStyle,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      mentalHealthGoals: mentalHealthGoals ?? this.mentalHealthGoals,
      preferredReminderTime: preferredReminderTime ?? this.preferredReminderTime,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Available mental health goals
class MentalHealthGoals {
  static const String reduceAnxiety = 'reduce_anxiety';
  static const String manageStress = 'manage_stress';
  static const String improveHappiness = 'improve_happiness';
  static const String betterSleep = 'better_sleep';
  static const String buildResilience = 'build_resilience';
  static const String improveRelationships = 'improve_relationships';
  static const String increaseConfidence = 'increase_confidence';
  static const String copingSkills = 'coping_skills';

  static String getDisplayName(String goal) {
    switch (goal) {
      case reduceAnxiety:
        return 'Reduce Anxiety';
      case manageStress:
        return 'Manage Stress';
      case improveHappiness:
        return 'Improve Happiness';
      case betterSleep:
        return 'Better Sleep';
      case buildResilience:
        return 'Build Resilience';
      case improveRelationships:
        return 'Improve Relationships';
      case increaseConfidence:
        return 'Increase Confidence';
      case copingSkills:
        return 'Develop Coping Skills';
      default:
        return goal;
    }
  }

  static IconData getIcon(String goal) {
    switch (goal) {
      case reduceAnxiety:
        return Icons.self_improvement;
      case manageStress:
        return Icons.spa;
      case improveHappiness:
        return Icons.sentiment_satisfied_alt;
      case betterSleep:
        return Icons.bedtime;
      case buildResilience:
        return Icons.fitness_center;
      case improveRelationships:
        return Icons.favorite;
      case increaseConfidence:
        return Icons.star;
      case copingSkills:
        return Icons.construction;
      default:
        return Icons.track_changes;
    }
  }

  static List<String> getAllGoals() {
    return [
      reduceAnxiety,
      manageStress,
      improveHappiness,
      betterSleep,
      buildResilience,
      improveRelationships,
      increaseConfidence,
      copingSkills,
    ];
  }
}

/// Communication style options
class CommunicationStyles {
  static const String supportive = 'supportive';
  static const String direct = 'direct';
  static const String encouraging = 'encouraging';
  static const String reflective = 'reflective';

  static String getDisplayName(String style) {
    switch (style) {
      case supportive:
        return 'Supportive & Gentle';
      case direct:
        return 'Direct & Practical';
      case encouraging:
        return 'Encouraging & Motivational';
      case reflective:
        return 'Reflective & Thoughtful';
      default:
        return style;
    }
  }

  static String getDescription(String style) {
    switch (style) {
      case supportive:
        return 'Warm, empathetic responses that validate your feelings';
      case direct:
        return 'Straightforward advice with actionable steps';
      case encouraging:
        return 'Positive reinforcement and motivational guidance';
      case reflective:
        return 'Deep, contemplative discussions to explore thoughts';
      default:
        return '';
    }
  }

  static List<String> getAllStyles() {
    return [supportive, direct, encouraging, reflective];
  }
}
