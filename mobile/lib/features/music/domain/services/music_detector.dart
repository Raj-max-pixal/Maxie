import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class MusicDetector {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentSong;
  String? _currentArtist;
  String? _currentApp;

  bool get isPlaying => _isPlaying;
  String? get currentSong => _currentSong;
  String? get currentArtist => _currentArtist;
  String? get currentApp => _currentApp;

  Future<void> initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    
    _audioPlayer.playbackEventStream.listen((event) {
      _isPlaying = _audioPlayer.playing;
    });
  }

  void updateMusicState({
    required bool playing,
    String? song,
    String? artist,
    String? app,
  }) {
    _isPlaying = playing;
    _currentSong = song;
    _currentArtist = artist;
    _currentApp = app;
  }

  String getMusicReaction() {
    if (!_isPlaying) {
      return [
        'Music stopped. Want me to pick something?',
        'Silence is nice too... sometimes.',
        'Missing the beats already!',
      ][(DateTime.now().millisecond) % 3];
    }

    final reactions = [
      'This song is fire! 🔥',
      'Damn, this goes hard! 💪',
      'Adding this to our favorites! ⭐',
      'Maximum vibe unlocked! ✨',
      'This one deserves replay! 🔄',
      '*dances to the beat* 💃',
      'You have great taste in music!',
      'This is my jam! 🎵',
    ];

    return reactions[(DateTime.now().millisecond) % reactions.length];
  }

  String getSadSongReaction() {
    return [
      '*sits quietly and listens* 😢',
      'This is beautiful but makes me sad...',
      'Sometimes sad songs hit different.',
      '*tiny tears* This is emotional.',
    ][(DateTime.now().millisecond) % 4];
  }

  String getHappySongReaction() {
    return [
      'Wooo! Party time! 🎉',
      '*jumps around excitedly*',
      'This energy! I love it! ⚡',
      'Let\'s dance together! 💃',
    ][(DateTime.now().millisecond) % 4];
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

final musicDetectorProvider = Provider<MusicDetector>((ref) {
  final detector = MusicDetector();
  ref.onDispose(() => detector.dispose());
  return detector;
});
