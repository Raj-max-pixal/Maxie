import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/voice/domain/models/voice_state.dart';
import 'package:maxie_mobile/features/voice/domain/repositories/voice_repository.dart';

final voiceRepositoryProvider = Provider<VoiceRepository>(
  (ref) => const PlaceholderVoiceRepository(),
);

final voiceStateProvider = FutureProvider<VoiceState>(
  (ref) => ref.watch(voiceRepositoryProvider).readState(),
);

class PlaceholderVoiceRepository implements VoiceRepository {
  const PlaceholderVoiceRepository();

  @override
  Future<void> handleCommand(String command) async {}

  @override
  Future<VoiceState> readState() async {
    return const VoiceState();
  }

  @override
  Future<void> saveState(VoiceState state) async {}
}
