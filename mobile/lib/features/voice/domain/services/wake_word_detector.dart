import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

class WakeWordDetector {
  final SpeechToText _stt = SpeechToText();
  final List<String> _wakeWords = [
    'hey maxie',
    'hello maxie',
    'maxie',
    'ok maxie',
  ];
  
  bool _isListening = false;
  bool _wakeWordDetected = false;
  String _detectedWord = '';

  bool get isListening => _isListening;
  bool get wakeWordDetected => _wakeWordDetected;
  String get detectedWord => _detectedWord;

  Future<void> initialize() async {
    await _stt.initialize();
  }

  Future<void> startListening({
    required Function(String) onWakeWordDetected,
  }) async {
    if (!_stt.isAvailable) {
      return;
    }

    _isListening = await _stt.listen(
      onResult: (result) {
        final text = result.recognizedWords.toLowerCase();
        
        for (final wakeWord in _wakeWords) {
          if (text.contains(wakeWord)) {
            _wakeWordDetected = true;
            _detectedWord = wakeWord;
            onWakeWordDetected(wakeWord);
            break;
          }
        }
      },
      listenFor: const Duration(seconds: 300), // 5 minutes
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: false,
      listenMode: ListenMode.confirmation,
      autoPunctuation: false,
    );
  }

  Future<void> stopListening() async {
    await _stt.stop();
    _isListening = false;
    _wakeWordDetected = false;
  }

  void reset() {
    _wakeWordDetected = false;
    _detectedWord = '';
  }

  bool get isAvailable => _stt.isAvailable;
}

final wakeWordDetectorProvider = Provider<WakeWordDetector>((ref) {
  return WakeWordDetector();
});
