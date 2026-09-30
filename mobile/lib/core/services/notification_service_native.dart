// flutter_local_notifications v22.3.0 API — ALL methods use named parameters.
// This file is only compiled when dart.library.io is available (Android/iOS).
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// Re-export so callers can reference PendingNotificationRequest via the
// notification_service.dart conditional export without importing the package directly.
export 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show PendingNotificationRequest;

/// Real notification service used on Android / iOS.
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

    if (!_timezonesInitialized) {
      tz_data.initializeTimeZones();
      _timezonesInitialized = true;
    }

    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    // v22.3.0: initialize() uses named params — settings: ...
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createChannels();
    _initialized = true;
  }

  Future<void> _createChannels() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelReminder, 'Reminders',
        description: 'General reminder notifications',
        importance: Importance.high,
      ),
    );
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelPet, 'Pet Notifications',
        description: 'Notifications about your MAXie pet',
      ),
    );
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelHabit, 'Habit Reminders',
        description: 'Daily habit tracking reminders',
        importance: Importance.high,
      ),
    );
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelGoal, 'Goal Reminders',
        description: 'Progress reminders for your goals',
        importance: Importance.high,
      ),
    );
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelMotivation, 'Daily Motivation',
        description: 'Motivational messages from MAXie',
        playSound: false,
        enableVibration: false,
      ),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  // ---------------------------------------------------------------------------
  // Basic Notification
  // ---------------------------------------------------------------------------

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
      enableLights: true,
    );

    // v22.3.0: show() uses named params — id:, title:, body:, notificationDetails:
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  // ---------------------------------------------------------------------------
  // Reminder Notifications
  // ---------------------------------------------------------------------------

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelReminder, 'Reminders',
      channelDescription: 'General reminder notifications',
      importance: Importance.high,
    );

    // v22.3.0: zonedSchedule() uses named params; uiLocalNotificationDateInterpretation removed
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelReminder(int id) async {
    // v22.3.0: cancel() uses named param — id:
    await _plugin.cancel(id: id);
  }

  // ---------------------------------------------------------------------------
  // Pet Hungry Notification
  // ---------------------------------------------------------------------------

  Future<void> showPetHungryNotification({
    required int id,
    required String petName,
    String emotion = 'hungry',
  }) async {
    final String title;
    final String body;

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

  Future<void> scheduleHabitReminder({
    required int id,
    required String habitName,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      channelHabit, 'Habit Reminders',
      channelDescription: 'Daily habit tracking reminders',
      importance: Importance.high,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: 'Habit Reminder: $habitName 📋',
      body: 'Don\'t forget to complete your habit: $habitName',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'habit',
    );

    debugPrint(
        'NotificationService: Scheduled habit reminder for "$habitName" at $hour:$minute');
  }

  Future<void> cancelHabitReminder(int id) async {
    await _plugin.cancel(id: id);
  }

  // ---------------------------------------------------------------------------
  // Goal Reminders
  // ---------------------------------------------------------------------------

  Future<void> scheduleGoalReminder({
    required int id,
    required String goalTitle,
    required String goalCategory,
    required DateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelGoal, 'Goal Reminders',
      channelDescription: 'Progress reminders for your goals',
      importance: Importance.high,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: 'Goal Progress: $goalTitle 🎯',
      body: 'Keep working on your $goalCategory goal: "$goalTitle"',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'goal',
    );
  }

  Future<void> cancelGoalReminder(int id) async {
    await _plugin.cancel(id: id);
  }

  // ---------------------------------------------------------------------------
  // Bulk Operations
  // ---------------------------------------------------------------------------

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return _plugin.pendingNotificationRequests();
  }

  // ---------------------------------------------------------------------------
  // Channel Configuration & Toggle
  // ---------------------------------------------------------------------------

  Future<bool> isGloballyEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? true;
  }

  Future<void> setGloballyEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
    if (!enabled) await cancelAll();
  }

  String _channelNameForId(String channelId) {
    switch (channelId) {
      case channelReminder:   return 'Reminders';
      case channelPet:        return 'Pet Notifications';
      case channelHabit:      return 'Habit Reminders';
      case channelGoal:       return 'Goal Reminders';
      case channelMotivation: return 'Daily Motivation';
      default:                return 'Notifications';
    }
  }
}
