import 'package:maxie_mobile/features/ai_companion/domain/models/companion_emotion.dart';

abstract interface class CompanionEmotionRepository {
  Future<CompanionEmotion> readEmotion();

  Future<void> saveEmotion(CompanionEmotion emotion);
}
