class PersonalityProfile {
  final String tone;
  final int humorLevel;
  final int energyLevel;
  final int cutenessLevel;
  final List<String> favoritePhrases;
  final List<String> insideJokes;
  final String nickname;

  PersonalityProfile({
    this.tone = 'playful',
    this.humorLevel = 7,
    this.energyLevel = 8,
    this.cutenessLevel = 10,
    this.favoritePhrases = const [
      'Let\'s do this!',
      'You got this!',
      'I believe in you!',
      'MAXie power! ⚡',
    ],
    this.insideJokes = const [],
    this.nickname = 'Bestie',
  });

  PersonalityProfile copyWith({
    String? tone,
    int? humorLevel,
    int? energyLevel,
    int? cutenessLevel,
    List<String>? favoritePhrases,
    List<String>? insideJokes,
    String? nickname,
  }) {
    return PersonalityProfile(
      tone: tone ?? this.tone,
      humorLevel: humorLevel ?? this.humorLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      cutenessLevel: cutenessLevel ?? this.cutenessLevel,
      favoritePhrases: favoritePhrases ?? this.favoritePhrases,
      insideJokes: insideJokes ?? this.insideJokes,
      nickname: nickname ?? this.nickname,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tone': tone,
      'humorLevel': humorLevel,
      'energyLevel': energyLevel,
      'cutenessLevel': cutenessLevel,
      'favoritePhrases': favoritePhrases,
      'insideJokes': insideJokes,
      'nickname': nickname,
    };
  }

  factory PersonalityProfile.fromJson(Map<String, dynamic> json) {
    return PersonalityProfile(
      tone: json['tone'] ?? 'playful',
      humorLevel: json['humorLevel'] ?? 7,
      energyLevel: json['energyLevel'] ?? 8,
      cutenessLevel: json['cutenessLevel'] ?? 10,
      favoritePhrases: List<String>.from(json['favoritePhrases'] ?? []),
      insideJokes: List<String>.from(json['insideJokes'] ?? []),
      nickname: json['nickname'] ?? 'Bestie',
    );
  }
}
