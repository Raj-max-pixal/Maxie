import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/services/voice/voice_providers.dart';

final voiceFoundationReadyProvider = FutureProvider<bool>((ref) async {
  await ref.watch(voiceServiceProvider).initialize();
  return true;
});
