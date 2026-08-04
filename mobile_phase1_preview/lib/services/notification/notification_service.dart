abstract interface class NotificationService {
  Future<void> initialize();

  Future<void> requestPermission();

  Future<void> scheduleCompanionNudge();
}
