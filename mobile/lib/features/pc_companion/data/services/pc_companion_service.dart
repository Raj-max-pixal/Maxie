import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// PC Companion State
class PCCompanionState {
  final bool isConnected;
  final int batteryLevel;
  final double cpuUsage;
  final double ramUsage;
  final String? clipboardContent;
  final String? lastNotification;
  final DateTime? lastSync;
  final String deviceId;

  const PCCompanionState({
    this.isConnected = false,
    this.batteryLevel = 0,
    this.cpuUsage = 0.0,
    this.ramUsage = 0.0,
    this.clipboardContent,
    this.lastNotification,
    this.lastSync,
    this.deviceId = '',
  });

  PCCompanionState copyWith({
    bool? isConnected,
    int? batteryLevel,
    double? cpuUsage,
    double? ramUsage,
    String? clipboardContent,
    String? lastNotification,
    DateTime? lastSync,
    String? deviceId,
  }) {
    return PCCompanionState(
      isConnected: isConnected ?? this.isConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      ramUsage: ramUsage ?? this.ramUsage,
      clipboardContent: clipboardContent ?? this.clipboardContent,
      lastNotification: lastNotification ?? this.lastNotification,
      lastSync: lastSync ?? this.lastSync,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}

/// PC Companion Service
/// Manages connection between phone and desktop companion
class PCCompanionService extends StateNotifier<PCCompanionState> {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _statusTimer;

  PCCompanionService() : super(const PCCompanionState()) {
    _loadSavedState();
  }

  void _loadSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString(AppConstants.pcConnectionKey) ?? '';
      state = state.copyWith(deviceId: deviceId);
    } catch (e) {
      debugPrint('PCCompanion: Error loading state: $e');
    }
  }

  /// Connect to desktop companion
  Future<bool> connect(String ipAddress, int port) async {
    try {
      final wsUrl = Uri.parse('ws://$ipAddress:$port');
      _channel = WebSocketChannel.connect(wsUrl);

      await _channel!.ready;

      state = state.copyWith(
        isConnected: true,
        lastSync: DateTime.now(),
      );

      _startHeartbeat();
      _startStatusPolling();

      debugPrint('PCCompanion: Connected to $ipAddress:$port');
      return true;
    } catch (e) {
      debugPrint('PCCompanion: Connection failed: $e');
      state = state.copyWith(isConnected: false);
      return false;
    }
  }

  /// Disconnect from desktop
  void disconnect() {
    _channel?.sink.close();
    _heartbeatTimer?.cancel();
    _statusTimer?.cancel();
    state = state.copyWith(isConnected: false);
    debugPrint('PCCompanion: Disconnected');
  }

  /// Send clipboard content to desktop
  Future<void> sendClipboard(String content) async {
    if (!state.isConnected || _channel == null) return;

    try {
      _channel!.sink.add(jsonEncode({
        'type': 'clipboard',
        'data': content,
        'timestamp': DateTime.now().toIso8601String(),
      }));
      state = state.copyWith(clipboardContent: content);
    } catch (e) {
      debugPrint('PCCompanion: Clipboard send failed: $e');
    }
  }

  /// Send notification to desktop
  Future<void> sendNotification(String title, String body) async {
    if (!state.isConnected || _channel == null) return;

    try {
      _channel!.sink.add(jsonEncode({
        'type': 'notification',
        'title': title,
        'body': body,
        'timestamp': DateTime.now().toIso8601String(),
      }));
      state = state.copyWith(
        lastNotification: '$title: $body',
      );
    } catch (e) {
      debugPrint('PCCompanion: Notification send failed: $e');
    }
  }

  /// Send file to desktop
  Future<bool> sendFile(String fileName, String filePath) async {
    if (!state.isConnected || _channel == null) return false;

    try {
      _channel!.sink.add(jsonEncode({
        'type': 'file_transfer',
        'fileName': fileName,
        'filePath': filePath,
        'timestamp': DateTime.now().toIso8601String(),
      }));
      return true;
    } catch (e) {
      debugPrint('PCCompanion: File send failed: $e');
      return false;
    }
  }

  /// Remote lock desktop
  Future<bool> remoteLock() async {
    if (!state.isConnected || _channel == null) return false;

    try {
      _channel!.sink.add(jsonEncode({
        'type': 'remote_action',
        'action': 'lock',
        'timestamp': DateTime.now().toIso8601String(),
      }));
      return true;
    } catch (e) {
      debugPrint('PCCompanion: Remote lock failed: $e');
      return false;
    }
  }

  /// Remote shutdown desktop
  Future<bool> remoteShutdown() async {
    if (!state.isConnected || _channel == null) return false;

    try {
      _channel!.sink.add(jsonEncode({
        'type': 'remote_action',
        'action': 'shutdown',
        'timestamp': DateTime.now().toIso8601String(),
      }));
      return true;
    } catch (e) {
      debugPrint('PCCompanion: Remote shutdown failed: $e');
      return false;
    }
  }

  /// Remote restart desktop
  Future<bool> remoteRestart() async {
    if (!state.isConnected || _channel == null) return false;

    try {
      _channel!.sink.add(jsonEncode({
        'type': 'remote_action',
        'action': 'restart',
        'timestamp': DateTime.now().toIso8601String(),
      }));
      return true;
    } catch (e) {
      debugPrint('PCCompanion: Remote restart failed: $e');
      return false;
    }
  }

  /// Get device ID
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String id = prefs.getString(AppConstants.pcConnectionKey) ?? '';
    if (id.isEmpty) {
      id = 'maxie_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(AppConstants.pcConnectionKey, id);
    }
    state = state.copyWith(deviceId: id);
    return id;
  }

  /// Start heartbeat to maintain connection
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_channel != null && state.isConnected) {
        try {
          _channel!.sink.add(jsonEncode({
            'type': 'heartbeat',
            'timestamp': DateTime.now().toIso8601String(),
          }));
        } catch (e) {
          debugPrint('PCCompanion: Heartbeat failed: $e');
          disconnect();
        }
      }
    });
  }

  /// Start status polling
  void _startStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // In production, receive actual status from desktop
      // Simulated status updates for now
      if (state.isConnected) {
        state = state.copyWith(
          batteryLevel: (85 + (DateTime.now().second % 15)).clamp(0, 100),
          cpuUsage: (20 + (DateTime.now().millisecond % 60)).toDouble(),
          ramUsage: (40 + (DateTime.now().millisecond % 30)).toDouble(),
          lastSync: DateTime.now(),
        );
      }
    });
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

/// PC Companion service provider
final pcCompanionServiceProvider =
    StateNotifierProvider<PCCompanionService, PCCompanionState>((ref) {
  return PCCompanionService();
});