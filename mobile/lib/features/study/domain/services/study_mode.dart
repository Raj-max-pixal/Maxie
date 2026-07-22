import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StudyMode {
  Timer? _pomodoroTimer;
  int _remainingSeconds = 25 * 60; // 25 minutes
  bool _isRunning = false;
  int _completedSessions = 0;
  int _totalStudyMinutes = 0;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  int get completedSessions => _completedSessions;
  int get totalStudyMinutes => _totalStudyMinutes;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> startPomodoro() async {
    if (_isRunning) return;
    
    _isRunning = true;
    _remainingSeconds = 25 * 60;
    
    _pomodoroTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
      } else {
        _completeSession();
        timer.cancel();
        _isRunning = false;
      }
    });
  }

  void pausePomodoro() {
    _pomodoroTimer?.cancel();
    _isRunning = false;
  }

  void resetPomodoro() {
    _pomodoroTimer?.cancel();
    _isRunning = false;
    _remainingSeconds = 25 * 60;
  }

  void _completeSession() {
    _completedSessions++;
    _totalStudyMinutes += 25;
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    final box = await Hive.openBox('maxie_memory');
    await box.put('studySessions', _completedSessions);
    await box.put('totalStudyMinutes', _totalStudyMinutes);
  }

  Future<void> loadProgress() async {
    final box = await Hive.openBox('maxie_memory');
    _completedSessions = box.get('studySessions', defaultValue: 0);
    _totalStudyMinutes = box.get('totalStudyMinutes', defaultValue: 0);
  }

  String getEncouragement() {
    final encouragements = [
      'Focus! You\'re doing great! 💪',
      'One more page, you got this! 📚',
      'Your future self will thank you! ⭐',
      'Stay focused, almost there! 🎯',
      'Knowledge is power! Keep going! 🧠',
      'You\'re making progress! Believe it! ✨',
      'No Instagram, just focus! 🚫📱',
      'Study mode: ACTIVATED! 🤓',
      'Distractions? Never heard of them! 😎',
      'You\'re a studying machine! 🤖',
    ];

    return encouragements[(DateTime.now().millisecond) % encouragements.length];
  }

  String getBreakReminder() {
    return [
      'Time for a break! Stretch those legs! 🚶',
      'Break time! Drink some water! 💧',
      'You earned it! Take a breather! 😌',
      '5-minute break! Relax a bit! ☕',
    ][(DateTime.now().millisecond) % 4];
  }

  String getStudyStreakMessage() {
    if (_completedSessions == 0) {
      return 'Start your first study session! 🚀';
    } else if (_completedSessions < 5) {
      return '$_completedSessions sessions done! Keep going! 🔥';
    } else if (_completedSessions < 10) {
      return '$_completedSessions sessions! You\'re on fire! ⚡';
    } else {
      return '$_completedSessions sessions! Study master! 🏆';
    }
  }

  void dispose() {
    _pomodoroTimer?.cancel();
  }
}

final studyModeProvider = Provider<StudyMode>((ref) {
  final studyMode = StudyMode();
  ref.onDispose(() => studyMode.dispose());
  return studyMode;
});
