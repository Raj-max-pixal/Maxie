abstract interface class FloatingCompanionOverlayService {
  Future<void> prepareOverlay();
}

abstract interface class NotificationListenerFoundation {
  Future<void> prepareNotificationAccess();
}

abstract interface class AccessibilityFoundation {
  Future<void> prepareAccessibilityBridge();
}

abstract interface class UsageStatsFoundation {
  Future<void> prepareUsageStats();
}

abstract interface class MediaSessionFoundation {
  Future<void> prepareMediaSession();
}

abstract interface class BatteryEventsFoundation {
  Future<void> prepareBatteryEvents();
}

abstract interface class DeviceSignalFoundation {
  Future<void> prepareChargingEvents();

  Future<void> prepareHeadphoneEvents();
}

abstract interface class AppDetectionFoundation {
  Future<void> prepareFutureAppDetection();

  Future<void> prepareMusicDetection();
}
