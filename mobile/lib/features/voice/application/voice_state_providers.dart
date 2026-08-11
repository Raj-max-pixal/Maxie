import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/voice/data/hive_voice_repository.dart';
import 'package:maxie_mobile/features/voice/domain/models/voice_state.dart';
import 'package:maxie_mobile/features/voice/domain/repositories/voice_repository.dart';
import 'package:maxie_mobile/services/storage/storage_providers.dart';

final voiceRepositoryProvider = Provider<VoiceRepository>(
  (ref) => HiveVoiceRepository(ref.watch(storageServiceProvider)),
);

final voiceStateProvider = FutureProvider<VoiceState>(
  (ref) => ref.watch(voiceRepositoryProvider).readState(),
);
