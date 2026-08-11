class VoiceState {
  const VoiceState({
    this.isListening = false,
    this.isSpeaking = false,
    this.wakeWordEnabled = false,
    this.conversationModeEnabled = false,
  });

  final bool isListening;
  final bool isSpeaking;
  final bool wakeWordEnabled;
  final bool conversationModeEnabled;

  VoiceState copyWith({
    bool? isListening,
    bool? isSpeaking,
    bool? wakeWordEnabled,
    bool? conversationModeEnabled,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      wakeWordEnabled: wakeWordEnabled ?? this.wakeWordEnabled,
      conversationModeEnabled:
          conversationModeEnabled ?? this.conversationModeEnabled,
    );
  }

  factory VoiceState.fromJson(Map<dynamic, dynamic> json) {
    return VoiceState(
      isListening: json['isListening'] as bool? ?? false,
      isSpeaking: json['isSpeaking'] as bool? ?? false,
      wakeWordEnabled: json['wakeWordEnabled'] as bool? ?? false,
      conversationModeEnabled:
          json['conversationModeEnabled'] as bool? ?? false,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'isListening': isListening,
      'isSpeaking': isSpeaking,
      'wakeWordEnabled': wakeWordEnabled,
      'conversationModeEnabled': conversationModeEnabled,
    };
  }
}
