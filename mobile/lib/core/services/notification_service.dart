import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Centralized notification service for MAXie Mobile.
/// Handles local notifications, scheduling, reminders, pet alerts, habits, and goals.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _prefsKey = 'notification_channels_enabled';

  // Channel IDs
  static const String channelReminder = 'maxie_reminders';
  static const String channelPet = 'maxie_pet';
  static const String channelHabit = 'maxie_habits';
  static const String channelGoal = 'maxie_goals';
  static const String channelMotivation = 'maxie_motivation';

  bool _initialized = false;
  bool _timezonesInitialized = false;

  /// Initialize notification plugin and request permissions.
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data for scheduled notifications
    if (!_timezonesInitialized) {
      tz_data.initializeTimeZones();
      _timezonesInitialized = true;
    }

    // Android channel configuration
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS (not used on non-web but kept for cross-platform)
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels
    await _createChannels();

    _initialized = true;
  }

  Future<void> _createChannels() async {
    // Reminders channel
    const AndroidNotificationChannel reminderChannel =
        AndroidNotificationChannel(
      channelReminder,
      'Reminders',
      description: 'General reminder notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderChannel);

    // Pet channel
    const AndroidNotificationChannel petChannel = AndroidNotificationChannel(
      channelPet,
      'Pet Notifications',
      description: 'Notifications about your MAXie pet',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(petChannel);

    // Habits channel
    const AndroidNotificationChannel habitChannel = AndroidNotificationChannel(
      channelHabit,
      'Habit Reminders',
      description: 'Daily habit tracking reminders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(habitChannel);

    // Goals channel
    const AndroidNotificationChannel goalChannel = AndroidNotificationChannel(
      channelGoal,
      'Goal Reminders',
      description: 'Progress reminders for your goals',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(goalChannel);

    // Motivation channel
    const AndroidNotificationChannel motivationChannel =
        AndroidNotificationChannel(
      channelMotivation,
      'Daily Motivation',
      description: 'Motivational messages from MAXie',
      importance: Importance.defaultImportance,
      playSound: false,
      enableVibration: false,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(motivationChannel);
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - can be used to navigate to specific screens
    debugPrint('Notification tapped: ${response.payload}');
  }

  // ---------------------------------------------------------------------------
  // Basic Notification
  // ---------------------------------------------------------------------------

  /// Show an immediate local notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = channelReminder,
    String? channelName,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName ?? _channelNameForId(channelId),
      channelDescription: 'Notifications for $channelId',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      ),
      payload: payload,
    );
  }

  // ---------------------------------------------------------------------------
  // Reminder Notifications
  // ---------------------------------------------------------------------------

  /// Schedule a one-time reminder notification.
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelReminder,
      'Reminders',
      channelDescription: 'General reminder notifications',
      importance: Importance.high,
      priority: Priority.defaultPriority,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancel a scheduled reminder by ID.
  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  // ---------------------------------------------------------------------------
  // Pet Hungry Notification
  // ---------------------------------------------------------------------------

  /// Notify user that their pet is hungry or needs attention.
  Future<void> showPetHungryNotification({
    required int id,
    required String petName,
    String emotion = 'hungry',
  }) async {
    String title;
    String body;

    switch (emotion) {
      case 'hungry':
        title = '$petName is hungry! 🍽️';
        body = 'Your pet needs feeding. Tap to open the pet screen.';
        break;
      case 'sleepy':
        title = '$petName is sleepy 😴';
        body = 'Time to let your pet rest. Tap to check.';
        break;
      case 'lonely':
        title = '$petName misses you 🥺';
        body = 'Spend some time with your pet! Tap to play.';
        break;
      case 'excited':
        title = '$petName is excited! 🎉';
        body = 'Come play with your pet right now!';
        break;
      default:
        title = '$petName needs attention 💕';
        body = 'Your pet is feeling $emotion. Tap to interact.';
    }

    await showNotification(
      id: id,
      title: title,
      body: body,
      channelId: channelPet,
      payload: 'pet',
    );
  }

  // ---------------------------------------------------------------------------
  // Habit Reminders
  // ---------------------------------------------------------------------------

  /// Schedule a daily habit reminder.
  Future<void> scheduleHabitReminder({
    required int id,
    required String habitName,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      channelHabit,
      'Habit Reminders',
      channelDescription: 'Daily habit tracking reminders',
      importance: Importance.high,
      priority: Priority.defaultPriority,
    );

    await _plugin.zonedSchedule(
      id,
      'Habit Reminder: $habitName 📋',
      'Don\'t forget to complete your habit: $habitName',
      scheduledDate,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'habit',
      // No matchAndroidDateTime: true because we want it to repeat
    );

    debugPrint(
        'NotificationService: Scheduled habit reminder for "$habitName" at $hour:$minute');
  }

  /// Cancel a habit reminder.
  Future<void> cancelHabitReminder(int id) async {
    await _plugin.cancel(id);
  }

  // ---------------------------------------------------------------------------
  // Goal Reminders
  // ---------------------------------------------------------------------------

  /// Schedule a goal reminder notification.
  Future<void> scheduleGoalReminder({
    required int id,
    required String goalTitle,
    required String goalCategory,
    required DateTime scheduledDate,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelGoal,
      'Goal Reminders',
      channelDescription: 'Progress reminders for your goals',
      importance: Importance.high,
      priority: Priority.defaultPriority,
    );

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      id,
      'Goal Progress: $goalTitle 🎯',
      'Keep working on your $goalCategory goal: "$goalTitle"',
      tzDate,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'goal',
    );
  }

  /// Cancel a goal reminder.
  Future<void> cancelGoalReminder(int id) async {
    await _plugin.cancel(id);
  }

  // ---------------------------------------------------------------------------
  // Bulk Operations
  // ---------------------------------------------------------------------------

  /// Cancel all pending notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Get pending notification requests (Android only).
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending;
  }

  // ---------------------------------------------------------------------------
  // Channel Configuration & Toggle
  // ---------------------------------------------------------------------------

  /// Check if notifications are globally enabled (from preferences).
  Future<bool> isGloballyEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? true;
  }

  /// Toggle all notifications globally.
  Future<void> setGloballyEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
    if (!enabled) {
      await cancelAll();
    }
  }

  String _channelNameForId(String channelId) {
    switch (channelId) {
      case channelReminder:
        return 'Reminders';
      case channelPet:
        return 'Pet Notifications';
      case channelHabit:
        return 'Habit Reminders';
      case channelGoal:
        return 'Goal Reminders';
      case channelMotivation:
        return 'Daily Motivation';
      default:
        return 'Notifications';
    }
  }
}