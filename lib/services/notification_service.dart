import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/user_affirmation_prefs.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_service.dart';
import 'dart:io';

/// Service for managing local notifications for daily affirmations
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;
  
  static const int dailyAffirmationNotificationId = 0;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android initialization
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      print('✅ Notification service initialized');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('📬 Notification tapped: ${response.payload}');
    // Navigate to affirmation screen
    // This will be handled by the app's navigation logic
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // Android 13+ requires notification permission
        if (await Permission.notification.isDenied) {
          final status = await Permission.notification.request();
          return status.isGranted;
        }
        return true;
      } else if (Platform.isIOS) {
        final granted = await _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return granted ?? false;
      }
      return true;
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        return await Permission.notification.isGranted;
      } else if (Platform.isIOS) {
          final granted = await _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
            ?.checkPermissions();
          // checkPermissions may return a platform-specific object in different
          // versions of the plugin; cast to dynamic to avoid static errors and
          // defensively read an 'alert' property if present.
          return (granted as dynamic)?.alert ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Error checking notification permissions: $e');
      return false;
    }
  }

  /// Schedule daily affirmation notification
  Future<void> scheduleDailyAffirmation({
    required String time, // HH:mm format
    String? customMessage,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Cancel existing notifications
      await _notifications.cancel(dailyAffirmationNotificationId);

      // Parse time
      final parts = time.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid time format. Expected HH:mm');
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Schedule notification
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      const androidDetails = AndroidNotificationDetails(
        'daily_affirmation',
        'Daily Affirmations',
        channelDescription: 'Daily mental health affirmations',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        dailyAffirmationNotificationId,
        'Your Daily Affirmation 💚',
        customMessage ?? 'Tap to read today\'s positive message',
        scheduledTZ,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ Daily affirmation scheduled for $time');
    } catch (e) {
      print('❌ Error scheduling daily affirmation: $e');
    }
  }

  /// Cancel daily affirmation notification
  Future<void> cancelDailyAffirmation() async {
    try {
      await _notifications.cancel(dailyAffirmationNotificationId);
      print('✅ Daily affirmation notification cancelled');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  /// Show immediate notification (for testing)
  Future<void> showTestNotification() async {
    if (!_initialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'test',
      'Test Notifications',
      channelDescription: 'Test notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999,
      'Test Notification',
      'This is a test notification from Mindful Chat',
      details,
    );
  }

  /// Get user affirmation preferences
  Future<UserAffirmationPrefs?> getUserPreferences() async {
    try {
      final userId = SupabaseAuthService.instance.currentUserId;
      if (userId == null) return null;

      final supabase = SupabaseService.client;
      final response = await supabase
          .from('user_affirmation_prefs')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      
      return UserAffirmationPrefs.fromJson(response);
    } catch (e) {
      print('❌ Error fetching user preferences: $e');
      return null;
    }
  }

  /// Update user affirmation preferences
  Future<bool> updateUserPreferences({
    required bool notificationEnabled,
    required String notificationTime,
  }) async {
    try {
      final userId = SupabaseAuthService.instance.currentUserId;
      if (userId == null) return false;

      final supabase = SupabaseService.client;
      
      // Check if preferences exist
      final existing = await getUserPreferences();

      if (existing == null) {
        // Insert new preferences
        await supabase.from('user_affirmation_prefs').insert({
          'user_id': userId,
          'notification_enabled': notificationEnabled,
          'notification_time': notificationTime,
        });
      } else {
        // Update existing preferences
        await supabase
            .from('user_affirmation_prefs')
            .update({
              'notification_enabled': notificationEnabled,
              'notification_time': notificationTime,
            })
            .eq('user_id', userId);
      }

      // Schedule or cancel notification
      if (notificationEnabled) {
        await scheduleDailyAffirmation(time: notificationTime);
      } else {
        await cancelDailyAffirmation();
      }

      print('✅ User preferences updated');
      return true;
    } catch (e) {
      print('❌ Error updating user preferences: $e');
      return false;
    }
  }

  /// Sync notification schedule with user preferences
  Future<void> syncNotificationSchedule() async {
    final prefs = await getUserPreferences();
    
    if (prefs == null || !prefs.notificationEnabled) {
      await cancelDailyAffirmation();
    } else {
      await scheduleDailyAffirmation(time: prefs.notificationTime);
    }
  }
}
