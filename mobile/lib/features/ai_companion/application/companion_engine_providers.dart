import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/companion_model.dart';
import 'package:maxie_mobile/features/ai_companion/domain/services/companion_engines.dart';

final companionMoodEngineProvider = Provider<MoodEngine>(
  (ref) => const DemoMoodEngine(),
);

final companionModelProvider = Provider<CompanionModel>((ref) {
  final mood = ref.watch(companionMoodEngineProvider).moodFor(DateTime.now());
  return CompanionModel(
    name: 'MAXie',
    mood: mood,
    message: const DemoEmotionManager().messageFor(mood),
  );
});

class DemoMoodEngine implements MoodEngine {
  const DemoMoodEngine();

  @override
  CompanionMood moodFor(DateTime moment) {
    final moods = CompanionMood.values;
    return moods[(moment.hour + moment.weekday) % moods.length];
  }
}

class DemoEmotionManager implements EmotionManager {
  const DemoEmotionManager();

  @override
  String messageFor(CompanionMood mood) {
    return switch (mood) {
      CompanionMood.motivating => "Let's win Shipathon.",
      CompanionMood.studyMode => "Today's a good day to learn.",
      CompanionMood.sleeping => "Don't forget to recharge yourself too.",
      CompanionMood.celebrating => "You're building something special.",
      _ => "I'm always here.",
    };
  }
}
