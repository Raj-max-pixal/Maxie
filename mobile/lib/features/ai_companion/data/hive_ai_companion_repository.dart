import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/config/storage_keys.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/features/ai_companion/domain/repositories/ai_companion_repository.dart';
import 'package:maxie_mobile/services/storage/storage_service.dart';

class HiveAiCompanionRepository implements AiCompanionRepository {
  const HiveAiCompanionRepository(this._storage);

  final StorageService _storage;

  @override
  Future<AiCompanionState> readState() async {
    final data = await _storage.read<Map<dynamic, dynamic>>(
      AppConstants.hiveCompanionBox,
      StorageKeys.companionState,
    );
    if (data == null) {
      return const AiCompanionState(
        presence: CompanionPresence.happy,
        statusMessage: 'Ready to help you build.',
      );
    }
    return AiCompanionState.fromJson(data);
  }

  @override
  Future<void> saveState(AiCompanionState state) {
    return _storage.write<Map<String, Object?>>(
      AppConstants.hiveCompanionBox,
      StorageKeys.companionState,
      state.toJson(),
    );
  }
}
