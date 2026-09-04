enum CompanionPresence {
  idle,
  happy,
  thinking,
  listening,
  typing,
  sleeping,
  celebrating,
  dancing,
  walking,
  excited,
}

class AiCompanionState {
  const AiCompanionState({
    this.presence = CompanionPresence.idle,
    this.displayName = 'MAXie',
    this.statusMessage = 'Ready when you are.',
  });

  final CompanionPresence presence;
  final String displayName;
  final String statusMessage;

  factory AiCompanionState.fromJson(Map<dynamic, dynamic> json) {
    return AiCompanionState(
      presence: CompanionPresence.values.byName(
        json['presence'] as String? ?? 'idle',
      ),
      displayName: json['displayName'] as String? ?? 'MAXie',
      statusMessage:
          json['statusMessage'] as String? ?? 'Ready when you are.',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'presence': presence.name,
      'displayName': displayName,
      'statusMessage': statusMessage,
    };
  }

  AiCompanionState copyWith({
    CompanionPresence? presence,
    String? displayName,
    String? statusMessage,
  }) {
    return AiCompanionState(
      presence: presence ?? this.presence,
      displayName: displayName ?? this.displayName,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
