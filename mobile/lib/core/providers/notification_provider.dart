import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

/// Singleton provider for the centralized notification service.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider to initialize notifications on app start.
final notificationInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(notificationServiceProvider);
  await service.initialize();
});

/// Provider to check/set global notification enabled state.
final notificationEnabledProvider =
    StateNotifierProvider<NotificationEnabledNotifier, bool>((ref) {
  return NotificationEnabledNotifier();
});

class NotificationEnabledNotifier extends StateNotifier<bool> {
  NotificationEnabledNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final enabled = await NotificationService().isGloballyEnabled();
    state = enabled;
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await NotificationService().setGloballyEnabled(enabled);
  }
}