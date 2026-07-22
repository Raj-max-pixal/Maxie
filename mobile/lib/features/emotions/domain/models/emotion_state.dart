class EmotionState {
  final String primaryEmotion;
  final double intensity;
  final DateTime lastUpdated;
  final Map<String, double> emotionFactors;

  EmotionState({
    this.primaryEmotion = 'happy',
    this.intensity = 0.7,
    DateTime? lastUpdated,
    Map<String, double>? emotionFactors,
  })  : lastUpdated = lastUpdated ?? DateTime.now(),
        emotionFactors = emotionFactors ?? {
          'happiness': 0.7,
          'energy': 0.8,
          'curiosity': 0.6,
          'affection': 0.9,
          'focus': 0.5,
          'playfulness': 0.8,
          'calm': 0.6,
        };

  EmotionState copyWith({
    String? primaryEmotion,
    double? intensity,
    DateTime? lastUpdated,
    Map<String, double>? emotionFactors,
  }) {
    return EmotionState(
      primaryEmotion: primaryEmotion ?? this.primaryEmotion,
      intensity: intensity ?? this.intensity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      emotionFactors: emotionFactors ?? this.emotionFactors,
    );
  }

  String getDisplayEmotion() {
    if (intensity < 0.3) return 'sleepy';
    if (intensity > 0.8) return 'excited';
    return primaryEmotion;
  }
}

enum EmotionType {
  happy,
  sleepy,
  excited,
  sad,
  focused,
  curious,
  playful,
  calm,
  embarrassed,
  confused,
  hungry,
  lazy,
  hyper,
  loving,
  worried,
}

extension EmotionTypeExtension on EmotionType {
  String get value {
    switch (this) {
      case EmotionType.happy:
        return 'happy';
      case EmotionType.sleepy:
        return 'sleepy';
      case EmotionType.excited:
        return 'excited';
      case EmotionType.sad:
        return 'sad';
      case EmotionType.focused:
        return 'focused';
      case EmotionType.curious:
        return 'curious';
      case EmotionType.playful:
        return 'playful';
      case EmotionType.calm:
        return 'calm';
      case EmotionType.embarrassed:
        return 'embarrassed';
      case EmotionType.confused:
        return 'confused';
      case EmotionType.hungry:
        return 'hungry';
      case EmotionType.lazy:
        return 'lazy';
      case EmotionType.hyper:
        return 'hyper';
      case EmotionType.loving:
        return 'loving';
      case EmotionType.worried:
        return 'worried';
    }
  }

  static EmotionType fromString(String value) {
    return EmotionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EmotionType.happy,
    );
  }
}
