enum CompanionEmotionType {
  happy,
  excited,
  playful,
  sleepy,
  hungry,
  sad,
  bored,
  curious,
  angry,
  neutral,
  satisfied,
  comforted,
}

class CompanionEmotion {
  const CompanionEmotion({
    required this.type,
    required this.intensity,
    required this.reason,
    required this.changedAt,
    required this.lastInteractionAt,
    this.expiresAt,
    this.reactionMessage,
  });

  factory CompanionEmotion.initial({DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    return CompanionEmotion(
      type: CompanionEmotionType.neutral,
      intensity: 0.45,
      reason: 'ready',
      changedAt: timestamp,
      lastInteractionAt: timestamp,
      reactionMessage: 'Ready when you are.',
    );
  }

  factory CompanionEmotion.fromJson(Map<dynamic, dynamic> json) {
    final now = DateTime.now();
    return CompanionEmotion(
      type: _emotionTypeFromName(json['type'] as String?),
      intensity: ((json['intensity'] as num?)?.toDouble() ?? 0.45).clamp(0, 1),
      reason: json['reason'] as String? ?? 'restored',
      changedAt: _dateFromJson(json['changedAt']) ?? now,
      expiresAt: _dateFromJson(json['expiresAt']),
      lastInteractionAt: _dateFromJson(json['lastInteractionAt']) ?? now,
      reactionMessage: json['reactionMessage'] as String?,
    );
  }

  final CompanionEmotionType type;
  final double intensity;
  final String reason;
  final DateTime changedAt;
  final DateTime? expiresAt;
  final DateTime lastInteractionAt;
  final String? reactionMessage;

  bool isExpired(DateTime now) => expiresAt != null && !expiresAt!.isAfter(now);

  CompanionEmotion copyWith({
    CompanionEmotionType? type,
    double? intensity,
    String? reason,
    DateTime? changedAt,
    DateTime? expiresAt,
    DateTime? lastInteractionAt,
    String? reactionMessage,
  }) {
    return CompanionEmotion(
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      reason: reason ?? this.reason,
      changedAt: changedAt ?? this.changedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      reactionMessage: reactionMessage ?? this.reactionMessage,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'type': type.name,
      'intensity': intensity,
      'reason': reason,
      'changedAt': changedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'lastInteractionAt': lastInteractionAt.toIso8601String(),
      'reactionMessage': reactionMessage,
    };
  }
}

CompanionEmotionType _emotionTypeFromName(String? name) {
  for (final type in CompanionEmotionType.values) {
    if (type.name == name) {
      return type;
    }
  }
  return CompanionEmotionType.neutral;
}

DateTime? _dateFromJson(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
