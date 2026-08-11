import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/config/storage_keys.dart';
import 'package:maxie_mobile/features/voice/domain/models/voice_state.dart';
import 'package:maxie_mobile/features/voice/domain/repositories/voice_repository.dart';
import 'package:maxie_mobile/services/storage/storage_service.dart';

class HiveVoiceRepository implements VoiceRepository {
  const HiveVoiceRepository(this._storage);

  final StorageService _storage;

  @override
  Future<void> handleCommand(String command) async {
    final normalized = command.trim().toLowerCase();
    if (normalized.isEmpty) {
      return;
    }

    final current = await readState();
    final next = current.copyWith(
      isListening: normalized.contains('listen') || current.isListening,
      isSpeaking: normalized.contains('speak') || current.isSpeaking,
      wakeWordEnabled:
          normalized.contains('wake word') || current.wakeWordEnabled,
      conversationModeEnabled:
          normalized.contains('conversation') ||
          current.conversationModeEnabled,
    );
    await saveState(next);
  }

  @override
  Future<VoiceState> readState() async {
    final data = await _storage.read<Map<dynamic, dynamic>>(
      AppConstants.hiveSettingsBox,
      StorageKeys.voiceState,
    );
    if (data == null) {
      return const VoiceState();
    }
    return VoiceState.fromJson(data);
  }

  @override
  Future<void> saveState(VoiceState state) {
    return _storage.write<Map<String, Object?>>(
      AppConstants.hiveSettingsBox,
      StorageKeys.voiceState,
      state.toJson(),
    );
  }
}
