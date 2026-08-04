import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/services/notification/notification_providers.dart';

final notificationFoundationReadyProvider = FutureProvider<bool>((ref) async {
  await ref.watch(notificationServiceProvider).initialize();
  return true;
});
