// Web stub for NotificationService.
// All methods are no-ops — flutter_local_notifications is not supported on web.
// Selected by the conditional export in notification_service.dart when
// dart.library.io is NOT available (i.e. Chrome / web targets).
//
// We define PendingNotificationRequest locally here so that activity_screen.dart
// can import it from notification_service.dart without touching the incompatible
// flutter_local_notifications web stubs.
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal data class matching the native PendingNotificationRequest interface.
class PendingNotificationRequest {
  final int id;
  final String? title;
  final String? body;
  final String? payload;
  const PendingNotificationRequest(this.id, this.title, this.body, this.payload);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  // Channel ID constants — kept identical so callers compile on all targets.
  static const String channelReminder = 'maxie_reminders';
  static const String channelPet = 'maxie_pet';
  static const String channelHabit = 'maxie_habits';
  static const String channelGoal = 'maxie_goals';
  static const String channelMotivation = 'maxie_motivation';

  Future<void> initialize() async {}

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = channelReminder,
    String? channelName,
  }) async {}

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {}

  Future<void> cancelReminder(int id) async {}

  Future<void> showPetHungryNotification({
    required int id,
    required String petName,
    String emotion = 'hungry',
  }) async {}

  Future<void> scheduleHabitReminder({
    required int id,
    required String habitName,
    required int hour,
    required int minute,
  }) async {}

  Future<void> cancelHabitReminder(int id) async {}

  Future<void> scheduleGoalReminder({
    required int id,
    required String goalTitle,
    required String goalCategory,
    required DateTime scheduledDate,
  }) async {}

  Future<void> cancelGoalReminder(int id) async {}

  Future<void> cancelAll() async {}

  Future<List<PendingNotificationRequest>> getPendingNotifications() async =>
      const [];

  Future<bool> isGloballyEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification_channels_enabled') ?? true;
  }

  Future<void> setGloballyEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_channels_enabled', enabled);
  }
}
