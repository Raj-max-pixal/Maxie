import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_companion/data/placeholder_ai_companion_repository.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/features/ai_companion/domain/repositories/ai_companion_repository.dart';

final aiCompanionRepositoryProvider = Provider<AiCompanionRepository>(
  (ref) => const PlaceholderAiCompanionRepository(),
);

final aiCompanionStateProvider = FutureProvider<AiCompanionState>((ref) {
  return ref.watch(aiCompanionRepositoryProvider).readState();
});
