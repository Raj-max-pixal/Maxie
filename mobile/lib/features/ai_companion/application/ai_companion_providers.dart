import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_companion/data/hive_ai_companion_repository.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/features/ai_companion/domain/repositories/ai_companion_repository.dart';
import 'package:maxie_mobile/services/storage/storage_providers.dart';

final aiCompanionRepositoryProvider = Provider<AiCompanionRepository>(
  (ref) => HiveAiCompanionRepository(ref.watch(storageServiceProvider)),
);

final aiCompanionStateProvider = FutureProvider<AiCompanionState>((ref) {
  return ref.watch(aiCompanionRepositoryProvider).readState();
});
