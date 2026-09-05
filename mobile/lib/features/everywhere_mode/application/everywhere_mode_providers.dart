import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/everywhere_mode/domain/services/everywhere_mode_services.dart';

final everywhereModeFoundationProvider = Provider<EverywhereModeFoundation>(
  (ref) => const EverywhereModeFoundation(),
);

final shimejiEnabledProvider = StateProvider<bool>((ref) => false);

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
  Future<void> prepareOverlay() async {
    final bool isActive = await FlutterOverlayWindow.isActive();
    if (isActive) {
      await FlutterOverlayWindow.closeOverlay();
    } else {
      if (await FlutterOverlayWindow.isPermissionGranted()) {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          flag: OverlayFlag.focusPointer,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.right,
          height: 400,
          width: 400,
        );
      } else {
        await FlutterOverlayWindow.requestPermission();
      }
    }
  }

  Future<void> stopOverlay() async {
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

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
  Future<void> prepareUsageStats() async {}
}
