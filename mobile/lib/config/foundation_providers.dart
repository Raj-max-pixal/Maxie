import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_chat/application/ai_settings_providers.dart';
import 'package:maxie_mobile/features/ai_chat/application/chat_controller.dart';
import 'package:maxie_mobile/features/ai_companion/application/ai_companion_providers.dart';
import 'package:maxie_mobile/features/ai_companion/application/companion_engine_providers.dart';
import 'package:maxie_mobile/features/everywhere_mode/application/everywhere_mode_providers.dart';
import 'package:maxie_mobile/features/floating_companion/application/floating_companion_providers.dart';
import 'package:maxie_mobile/features/memory/application/memory_manager.dart';
import 'package:maxie_mobile/features/memory/application/memory_providers.dart';
import 'package:maxie_mobile/features/monetization/application/monetization_providers.dart';
import 'package:maxie_mobile/features/notification/application/notification_foundation_providers.dart';
import 'package:maxie_mobile/features/pet/application/pet_providers.dart';
import 'package:maxie_mobile/features/voice/application/voice_foundation_providers.dart';
import 'package:maxie_mobile/features/voice/application/voice_state_providers.dart';
import 'package:maxie_mobile/services/storage/storage_providers.dart';

final appFoundationProvider = Provider<void>((ref) {
  ref
    ..watch(storageServiceProvider)
    ..watch(aiCompanionRepositoryProvider)
    ..watch(aiCompanionStateProvider)
    ..watch(companionMoodEngineProvider)
    ..watch(companionModelProvider)
    ..watch(aiRepositoryProvider)
    ..watch(conversationRepositoryProvider)
    ..watch(aiSettingsProvider)
    ..watch(petRepositoryProvider)
    ..watch(petStateProvider)
    ..watch(memoryRepositoryProvider)
    ..watch(memoryListProvider)
    ..watch(memoryBrainServiceProvider)
    ..watch(monetizationStateProvider)
    ..watch(floatingCompanionStateProvider)
    ..watch(everywhereModeFoundationProvider)
    ..watch(notificationFoundationReadyProvider)
    ..watch(voiceFoundationReadyProvider)
    ..watch(voiceRepositoryProvider)
    ..watch(voiceStateProvider);
});
