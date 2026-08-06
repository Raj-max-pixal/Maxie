import 'package:maxie_mobile/features/ai_companion/domain/models/companion_model.dart';

abstract interface class MoodEngine {
  CompanionMood moodFor(DateTime moment);
}

abstract interface class EmotionManager {
  String messageFor(CompanionMood mood);
}

abstract interface class ReactionManager {
  CompanionModel reactTo(String event);
}

abstract interface class CompanionAnimationController {
  String animationKeyFor(CompanionMood mood);
}

abstract interface class SpeechBubbleController {
  String bubbleFor(CompanionMood mood);
}
