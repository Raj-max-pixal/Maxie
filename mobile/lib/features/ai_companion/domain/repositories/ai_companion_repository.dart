import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';

abstract interface class AiCompanionRepository {
  Future<AiCompanionState> readState();

  Future<void> saveState(AiCompanionState state);
}
