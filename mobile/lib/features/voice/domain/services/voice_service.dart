import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  bool _isListening = false;
  bool _isSpeaking = false;
  String _lastRecognizedText = '';

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get lastRecognizedText => _lastRecognizedText;

  Future<void> initialize() async {
    await _initTts();
    await _initStt();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.2);
    await _tts.setVolume(1.0);
    
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });
    
    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
    });
  }

  Future<void> _initStt() async {
    await _stt.initialize();
    
    _stt.setRecognitionResultHandler((result) {
      _lastRecognizedText = result.recognizedWords;
    });
    
    _stt.setSoundLevelHandler((level) {
      // Sound level feedback
    });
    
    _stt.setErrorHandler((error) {
      _isListening = false;
    });
  }

  Future<void> speak(String text) async {
    if (_isSpeaking) {
      await _tts.stop();
    }
    
    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  Future<bool> startListening() async {
    if (!_stt.isAvailable) {
      return false;
    }
    
    _isListening = await _stt.listen(
      onResult: (result) {
        _lastRecognizedText = result.recognizedWords;
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      onSoundLevelChange: (level) {
        // Handle sound level changes
      },
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
      autoPunctuation: true,
    );
    
    return _isListening;
  }

  Future<void> stopListening() async {
    await _stt.stop();
    _isListening = false;
  }

  String get lastWords => _lastRecognizedText;

  bool get isAvailable => _stt.isAvailable;

  Future<void> setVoiceSettings({
    String? language,
    double? speechRate,
    double? pitch,
    double? volume,
  }) async {
    if (language != null) {
      await _tts.setLanguage(language);
    }
    if (speechRate != null) {
      await _tts.setSpeechRate(speechRate);
    }
    if (pitch != null) {
      await _tts.setPitch(pitch);
    }
    if (volume != null) {
      await _tts.setVolume(volume);
    }
  }

  void dispose() {
    _tts.stop();
    _stt.stop();
  }
}

final voiceServiceProvider = Provider<VoiceService>((ref) {
  final voiceService = VoiceService();
  ref.onDispose(() => voiceService.dispose());
  return voiceService;
});
