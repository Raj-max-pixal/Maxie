import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/core/services/native_service.dart';
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
      // resizeOverlay uses dp, unlike showOverlay's physical-pixel arguments.
      await FlutterOverlayWindow.updateFlag(OverlayFlag.defaultFlag);
      await FlutterOverlayWindow.resizeOverlay(240, 254, true);
      return;
    }
    var granted = await FlutterOverlayWindow.isPermissionGranted();
    if (!granted) {
      granted = await FlutterOverlayWindow.requestPermission() ?? false;
    }
    if (!granted) {
      throw StateError('Display-over-other-apps permission was not granted.');
    }
    final view = PlatformDispatcher.instance.views.first;
    final density = view.devicePixelRatio;
    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.right,
      // Plugin 0.4.5 passes these directly to WindowManager in physical pixels.
      height: math.min(
        (254 * density).ceil(),
        view.physicalSize.height.floor(),
      ),
      width: math.min((240 * density).ceil(), view.physicalSize.width.floor()),
    );
  }

  Future<void> stopOverlay() async {
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  @override
  Future<void> prepareAccessibilityBridge() =>
      NativeService.openAccessibilitySettings();

  @override
  Future<void> prepareBatteryEvents() async {}

  @override
  Future<void> prepareChargingEvents() async {}

  @override
  Future<void> prepareFutureAppDetection() async {}

  @override
  Future<void> prepareHeadphoneEvents() async {}

  @override
  Future<void> prepareMediaSession() async {
    if (!await NativeService.checkNotificationPermission()) {
      await NativeService.openNotificationSettings();
    }
  }

  @override
  Future<void> prepareMusicDetection() => prepareMediaSession();

  @override
  Future<void> prepareNotificationAccess() =>
      NativeService.openNotificationSettings();

  @override
  Future<void> prepareUsageStats() async {}
}
