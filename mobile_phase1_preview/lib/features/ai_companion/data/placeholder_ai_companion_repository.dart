import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/features/ai_companion/domain/repositories/ai_companion_repository.dart';

class PlaceholderAiCompanionRepository implements AiCompanionRepository {
  const PlaceholderAiCompanionRepository();

  @override
  Future<AiCompanionState> readState() async {
    return const AiCompanionState();
  }

  @override
  Future<void> saveState(AiCompanionState state) async {}
}
