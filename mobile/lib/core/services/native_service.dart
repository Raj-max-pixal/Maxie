import 'package:flutter/services.dart';

class NativeService {
  static const MethodChannel _channel = MethodChannel('com.maxie.mobile/native');
  static const MethodChannel _overlayChannel = MethodChannel('com.maxie.mobile/overlay');

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
      final result = await _channel.invokeMethod('checkAccessibilityPermission');
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
