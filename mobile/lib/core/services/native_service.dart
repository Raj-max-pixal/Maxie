import 'package:flutter/services.dart';

class NativeService {
  static const MethodChannel _channel = MethodChannel(
    'com.maxie.mobile/native',
  );
  static const MethodChannel _overlayChannel = MethodChannel(
    'com.maxie.mobile/overlay',
  );
  static const EventChannel _integrationEvents = EventChannel(
    'com.maxie.mobile/integration_events',
  );

  /// Emits only after the user enables Notification Access or MAXie's
  /// YouTube-only accessibility service in Android Settings.
  static Stream<Map<String, dynamic>> get integrationEvents =>
      _integrationEvents
          .receiveBroadcastStream()
          .where((event) => event is Map)
          .map((event) => Map<String, dynamic>.from(event as Map));

  // Overlay Permissions
  static Future<bool> checkOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod('checkOverlayPermission');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      // Handle error
    }
  }

  // Accessibility Permissions
  static Future<bool> checkAccessibilityPermission() async {
    try {
      final result = await _channel.invokeMethod(
        'checkAccessibilityPermission',
      );
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      // Handle error
    }
  }

  // Notification Permissions
  static Future<bool> checkNotificationPermission() async {
    try {
      final result = await _channel.invokeMethod('checkNotificationPermission');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  static Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } catch (e) {
      // Handle error
    }
  }

  /// Active media sessions are available only while Notification Access is on.
  static Future<List<Map<String, dynamic>>> activeMediaSessions() async {
    try {
      final sessions = await _channel.invokeMethod<List<dynamic>>(
        'getActiveMediaSessions',
      );
      return sessions
              ?.whereType<Map>()
              .map((session) => Map<String, dynamic>.from(session))
              .toList() ??
          const [];
    } catch (_) {
      return const [];
    }
  }

  // Overlay Service Control
  static Future<void> startOverlay() async {
    try {
      await _overlayChannel.invokeMethod('startOverlay');
    } catch (e) {
      // Handle error
    }
  }

  static Future<void> stopOverlay() async {
    try {
      await _overlayChannel.invokeMethod('stopOverlay');
    } catch (e) {
      // Handle error
    }
  }

  static Future<void> updateOverlayPosition(int x, int y) async {
    try {
      await _overlayChannel.invokeMethod('updateOverlayPosition', {
        'x': x,
        'y': y,
      });
    } catch (e) {
      // Handle error
    }
  }
}
