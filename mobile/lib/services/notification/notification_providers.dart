import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/services/notification/notification_service.dart';

class PlaceholderNotificationService implements NotificationService {
  const PlaceholderNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> scheduleCompanionNudge() async {}
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => const PlaceholderNotificationService(),
);
