import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/gemini_repository.dart';
import '../data/models/personality_profile.dart';
import '../../home/presentation/providers/maxie_state_provider.dart';

class AIService {
  final GeminiRepository _geminiRepository;

  AIService({required GeminiRepository geminiRepository})
      : _geminiRepository = geminiRepository;

  Future<String> chatWithMaxie(
    String userMessage,
    PersonalityProfile personality,
    String currentEmotion,
    int friendshipLevel,
    String currentActivity,
  ) async {
    return await _geminiRepository.generateResponse(
      userMessage: userMessage,
      personality: personality,
      currentEmotion: currentEmotion,
      friendshipLevel: friendshipLevel,
      currentActivity: currentActivity,
    );
  }

  Future<String> reactToApp(
    String appPackage,
    String appName,
    PersonalityProfile personality,
    int friendshipLevel,
  ) async {
    return await _geminiRepository.generateContextualReaction(
      appPackage: appPackage,
      appName: appName,
      personality: personality,
      friendshipLevel: friendshipLevel,
    );
  }

  String getEmotionalResponse(
    String trigger,
    String currentEmotion,
    int friendshipLevel,
  ) {
    // Pre-defined emotional responses for common triggers
    final responses = _getEmotionalResponses(trigger, currentEmotion, friendshipLevel);
    return responses[(DateTime.now().millisecond) % responses.length];
  }

  List<String> _getEmotionalResponses(
    String trigger,
    String emotion,
    int friendshipLevel,
  ) {
    switch (trigger) {
      case 'battery_low':
        return [
          'I\'m getting hungry... ⚡',
          'Low battery! Time to charge! 🔋',
          'My energy is draining... ⚡',
        ];
      case 'battery_charging':
        return [
          'Nom nom nom... charging up! 🔋',
          'Energy incoming! ⚡',
          'Recharging my cuteness! ✨',
        ];
      case 'battery_full':
        return [
          'Full energy! Let\'s go! ⚡',
          'I\'m fully charged and ready! 🔋',
          'Maximum power achieved! ⚡',
        ];
      case 'morning':
        return [
          'Good morning! *stretches* Rise and shine! ☀️',
          'Morning! Ready to conquer the day? 🌅',
          'Wakey wakey! Let\'s do this! ☀️',
        ];
      case 'night':
        return [
          'Nighty night! Sweet dreams! 🌙',
          'Time to sleep! I\'ll be here when you wake up 😴',
          'Good night! Rest well! 🌙',
        ];
      default:
        return [
          'I\'m here with you! 🐾',
          'Whatever you need, I\'m here!',
          'Got your back! 💪',
        ];
    }
  }
}

final aiServiceProvider = Provider<AIService>((ref) {
  // This will be initialized with the actual API key from settings
  throw UnimplementedError('AI Service requires Gemini API key');
});
