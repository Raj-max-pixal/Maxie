import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_companion/application/ai_companion_providers.dart';
import 'package:maxie_mobile/features/floating_companion/application/floating_companion_providers.dart';
import 'package:maxie_mobile/features/memory/application/memory_providers.dart';
import 'package:maxie_mobile/features/notification/application/notification_foundation_providers.dart';
import 'package:maxie_mobile/features/pet/application/pet_providers.dart';
import 'package:maxie_mobile/features/voice/application/voice_foundation_providers.dart';
import 'package:maxie_mobile/services/storage/storage_providers.dart';

final appFoundationProvider = Provider<void>((ref) {
  ref
    ..watch(storageServiceProvider)
    ..watch(aiCompanionRepositoryProvider)
    ..watch(aiCompanionStateProvider)
    ..watch(petRepositoryProvider)
    ..watch(petStateProvider)
    ..watch(memoryRepositoryProvider)
    ..watch(memoryListProvider)
    ..watch(floatingCompanionStateProvider)
    ..watch(notificationFoundationReadyProvider)
    ..watch(voiceFoundationReadyProvider);
});
