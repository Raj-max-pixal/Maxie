import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:maxie_mobile/services/voice/voice_service.dart';
import 'package:speech_to_text/speech_to_text.dart';

class DeviceVoiceService implements VoiceService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _ttsReady = false;
  bool _speechReady = false;
  bool _isSpeaking = false;
  double _volume = 1;
  String _lastWords = '';

  @override
  String get lastWords => _lastWords;

  @override
  Future<void> initialize() async {
    await _initializeTts();
    if (_speechReady) return;
    _speechReady = await _speechToText.initialize();
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _initializeTts();
    if (_isSpeaking) await _tts.stop();
    _isSpeaking = true;
    await _tts.speak(text);
  }

  @override
  Future<bool> startListening() async {
    await initialize();
    if (!_speechReady) return false;
    final started = await _speechToText.listen(
      onResult: (result) => _lastWords = result.recognizedWords,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
      cancelOnError: true,
    );
    return started == true;
  }

  @override
  Future<void> stopListening() => _speechToText.stop();

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0).toDouble();
    await _initializeTts();
    await _tts.setVolume(_volume);
  }

  Future<void> _initializeTts() async {
    if (_ttsReady) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.2);
    await _tts.setVolume(_volume);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((_) => _isSpeaking = false);
    _ttsReady = true;
  }

  Future<void> dispose() async {
    await _tts.stop();
    await _speechToText.stop();
  }
}

final voiceServiceProvider = Provider<VoiceService>((ref) {
  final service = DeviceVoiceService();
  ref.onDispose(service.dispose);
  return service;
});
