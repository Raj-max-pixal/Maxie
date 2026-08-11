import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/config/storage_keys.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/companion_emotion.dart';
import 'package:maxie_mobile/features/ai_companion/domain/repositories/companion_emotion_repository.dart';
import 'package:maxie_mobile/services/storage/storage_service.dart';

class HiveCompanionEmotionRepository implements CompanionEmotionRepository {
  const HiveCompanionEmotionRepository(this._storage);

  final StorageService _storage;

  @override
  Future<CompanionEmotion> readEmotion() async {
    final data = await _storage.read<Map<dynamic, dynamic>>(
      AppConstants.hiveCompanionBox,
      StorageKeys.companionEmotion,
    );
    if (data == null) {
      return CompanionEmotion.initial();
    }
    return CompanionEmotion.fromJson(data);
  }

  @override
  Future<void> saveEmotion(CompanionEmotion emotion) {
    return _storage.write<Map<String, Object?>>(
      AppConstants.hiveCompanionBox,
      StorageKeys.companionEmotion,
      emotion.toJson(),
    );
  }
}
