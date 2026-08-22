import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/emotion_state.dart';

class EmotionEngine {
  EmotionState _currentState = EmotionState();

  EmotionState get currentState => _currentState;

  void updateEmotion({
    String? primaryEmotion,
    double? intensity,
    Map<String, double>? emotionFactors,
  }) {
    _currentState = _currentState.copyWith(
      primaryEmotion: primaryEmotion,
      intensity: intensity,
      emotionFactors: emotionFactors,
    );
  }

  void adjustEmotionFactor(String factor, double delta) {
    final factors = Map<String, double>.from(_currentState.emotionFactors);
    factors[factor] = (factors[factor] ?? 0.5) + delta;
    factors[factor] = factors[factor]!.clamp(0.0, 1.0);
    
    _currentState = _currentState.copyWith(emotionFactors: factors);
    _recalculatePrimaryEmotion();
  }

  void _recalculatePrimaryEmotion() {
    final factors = _currentState.emotionFactors;
    String highestEmotion = 'happy';
    double highestValue = 0.0;

    factors.forEach((emotion, value) {
      if (value > highestValue) {
        highestValue = value;
        highestEmotion = emotion;
      }
    });

    _currentState = _currentState.copyWith(primaryEmotion: highestEmotion);
  }

  void reactToActivity(String activity) {
    switch (activity) {
      case 'whatsapp':
      case 'instagram':
      case 'facebook':
      case 'twitter':
        adjustEmotionFactor('curiosity', 0.2);
        adjustEmotionFactor('playfulness', 0.1);
        break;
      case 'spotify':
      case 'youtube_music':
        adjustEmotionFactor('happiness', 0.3);
        adjustEmotionFactor('energy', 0.2);
        break;
      case 'coding':
      case 'github':
      case 'vscode':
        adjustEmotionFactor('focus', 0.3);
        adjustEmotionFactor('curiosity', 0.1);
        break;
      case 'studying':
      case 'coursera':
      case 'udemy':
        adjustEmotionFactor('focus', 0.4);
        adjustEmotionFactor('calm', 0.2);
        break;
      case 'gaming':
        adjustEmotionFactor('energy', 0.4);
        adjustEmotionFactor('playfulness', 0.3);
        break;
      case 'reading':
        adjustEmotionFactor('calm', 0.3);
        adjustEmotionFactor('curiosity', 0.2);
        break;
      default:
        adjustEmotionFactor('curiosity', 0.1);
    }
  }

  void reactToTimeOfDay(int hour) {
    if (hour >= 5 && hour < 12) {
      // Morning
      adjustEmotionFactor('energy', 0.3);
      adjustEmotionFactor('happiness', 0.2);
    } else if (hour >= 12 && hour < 17) {
      // Afternoon
      adjustEmotionFactor('focus', 0.2);
      adjustEmotionFactor('energy', 0.1);
    } else if (hour >= 17 && hour < 21) {
      // Evening
      adjustEmotionFactor('calm', 0.2);
      adjustEmotionFactor('playfulness', 0.2);
    } else {
      // Night
      adjustEmotionFactor('sleepy', 0.4);
      adjustEmotionFactor('calm', 0.3);
      adjustEmotionFactor('energy', -0.3);
    }
  }

  void reactToBatteryLevel(int level, bool isCharging) {
    if (isCharging) {
      adjustEmotionFactor('happiness', 0.2);
      adjustEmotionFactor('calm', 0.1);
    } else if (level < 20) {
      adjustEmotionFactor('worried', 0.3);
      adjustEmotionFactor('energy', -0.2);
    } else if (level > 80) {
      adjustEmotionFactor('energy', 0.2);
      adjustEmotionFactor('happiness', 0.1);
    }
  }

  void reactToInteraction(String interactionType) {
    switch (interactionType) {
      case 'tap':
        adjustEmotionFactor('affection', 0.1);
        adjustEmotionFactor('playfulness', 0.1);
        break;
      case 'double_tap':
        adjustEmotionFactor('excitement', 0.3);
        adjustEmotionFactor('affection', 0.2);
        break;
      case 'long_press':
        adjustEmotionFactor('calm', 0.2);
        adjustEmotionFactor('sleepy', 0.1);
        break;
      case 'chat':
        adjustEmotionFactor('affection', 0.2);
        adjustEmotionFactor('curiosity', 0.1);
        break;
    }
  }

  void decayEmotions() {
    // Gradually decay emotions over time
    final factors = Map<String, double>.from(_currentState.emotionFactors);
    
    factors.forEach((emotion, value) {
      if (emotion != 'affection') {
        factors[emotion] = value * 0.99; // 1% decay
      }
    });

    _currentState = _currentState.copyWith(emotionFactors: factors);
  }

  String getEmotionalResponse(String trigger) {
    final emotion = _currentState.getDisplayEmotion();
    final responses = _getResponsesForEmotion(emotion, trigger);
    return responses[(DateTime.now().millisecond) % responses.length];
  }

  List<String> _getResponsesForEmotion(String emotion, String trigger) {
    switch (emotion) {
      case 'happy':
        return [
          'I\'m so happy right now! 🎉',
          'This is the best day ever!',
          'I love being with you!',
          '*happy tail wags*',
        ];
      case 'sleepy':
        return [
          '*yawns* So sleepy... 😴',
          'Maybe a quick nap?',
          'My eyes are getting heavy...',
          'Zzz... just kidding!',
        ];
      case 'excited':
        return [
          'OMG THIS IS AMAZING! 🎉',
          'I\'m so excited I can\'t sit still!',
          'Wooooo! Let\'s go!',
          '*bounces around excitedly*',
        ];
      case 'sad':
        return [
          'I\'m feeling a bit down...',
          'Need a hug? 🤗',
          'It\'s okay to feel sad sometimes.',
          '*sad noises*',
        ];
      case 'focused':
        return [
          'In the zone! 💪',
          'Focus mode activated!',
          'Let\'s get this done!',
          'Nothing can distract me now!',
        ];
      default:
        return [
          'I\'m here with you! 🐾',
          'Whatever you need, I\'m here!',
          'Got your back!',
        ];
    }
  }

  void reset() {
    _currentState = EmotionState();
  }
}

final emotionEngineProvider = Provider<EmotionEngine>((ref) {
  return EmotionEngine();
});
