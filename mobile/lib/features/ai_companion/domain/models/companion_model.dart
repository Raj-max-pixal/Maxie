enum CompanionMood {
  idle,
  happy,
  thinking,
  typing,
  listening,
  sleeping,
  dancing,
  excited,
  celebrating,
  motivating,
  studyMode,
  working,
}

class CompanionModel {
  const CompanionModel({
    required this.name,
    required this.mood,
    required this.message,
    this.friendshipLevel = 12,
  });

  final String name;
  final CompanionMood mood;
  final String message;
  final int friendshipLevel;
}
