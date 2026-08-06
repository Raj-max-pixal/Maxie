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
}
