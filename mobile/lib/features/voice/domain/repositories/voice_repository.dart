import 'package:maxie_mobile/features/voice/domain/models/voice_state.dart';

abstract interface class VoiceRepository {
  Future<VoiceState> readState();

  Future<void> saveState(VoiceState state);

  Future<void> handleCommand(String command);
}
