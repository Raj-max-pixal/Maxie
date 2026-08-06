import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/everywhere_mode/domain/services/everywhere_mode_services.dart';

final everywhereModeFoundationProvider = Provider<EverywhereModeFoundation>(
  (ref) => const EverywhereModeFoundation(),
);

class EverywhereModeFoundation
    implements
        FloatingCompanionOverlayService,
        NotificationListenerFoundation,
        AccessibilityFoundation,
        UsageStatsFoundation,
        MediaSessionFoundation,
        BatteryEventsFoundation,
        DeviceSignalFoundation,
        AppDetectionFoundation {
  const EverywhereModeFoundation();

  @override
  Future<void> prepareAccessibilityBridge() async {}

  @override
  Future<void> prepareBatteryEvents() async {}

  @override
  Future<void> prepareChargingEvents() async {}

  @override
  Future<void> prepareFutureAppDetection() async {}

  @override
  Future<void> prepareHeadphoneEvents() async {}

  @override
  Future<void> prepareMediaSession() async {}

  @override
  Future<void> prepareMusicDetection() async {}

  @override
  Future<void> prepareNotificationAccess() async {}

  @override
  Future<void> prepareOverlay() async {}

  @override
  Future<void> prepareUsageStats() async {}
}
