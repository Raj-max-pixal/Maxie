abstract interface class VoiceService {
  Future<void> initialize();

  Future<bool> startListening();

  Future<void> stopListening();

  Future<void> speak(String text);

  Future<void> setVolume(double volume);

  String get lastWords;
}
