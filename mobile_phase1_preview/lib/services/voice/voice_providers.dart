import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/services/voice/voice_service.dart';

class PlaceholderVoiceService implements VoiceService {
  const PlaceholderVoiceService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> startListening() async {}

  @override
  Future<void> stopListening() async {}
}

final voiceServiceProvider = Provider<VoiceService>(
  (ref) => const PlaceholderVoiceService(),
);
