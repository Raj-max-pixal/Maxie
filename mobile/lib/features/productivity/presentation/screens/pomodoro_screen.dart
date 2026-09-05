import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';

enum PomodoroState { focus, shortBreak, longBreak }
enum TimerStatus { idle, running, paused }

class PomodoroSession {
  final int completedPomodoros;
  final PomodoroState currentState;
  final TimerStatus status;
  final int secondsRemaining;
  final int totalSeconds;

  const PomodoroSession({
    this.completedPomodoros = 0,
    this.currentState = PomodoroState.focus,
    this.status = TimerStatus.idle,
    this.secondsRemaining = 25 * 60,
    this.totalSeconds = 25 * 60,
  });

  PomodoroSession copyWith({
    int? completedPomodoros,
    PomodoroState? currentState,
    TimerStatus? status,
    int? secondsRemaining,
    int? totalSeconds,
  }) {
    return PomodoroSession(
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      currentState: currentState ?? this.currentState,
      status: status ?? this.status,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      totalSeconds: totalSeconds ?? this.totalSeconds,
    );
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroSession> {
  Timer? _timer;

  PomodoroNotifier() : super(const PomodoroSession());

  int get _focusDuration => 25 * 60;
  int get _shortBreakDuration => 5 * 60;
  int get _longBreakDuration => 15 * 60;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        _timer?.cancel();
        _onSessionComplete();
      }
    });
  }

  void _onSessionComplete() {
    if (state.currentState == PomodoroState.focus) {
      final newCompleted = state.completedPomodoros + 1;
      final isLongBreak = newCompleted % 4 == 0;
      state = state.copyWith(
        completedPomodoros: newCompleted,
        currentState: isLongBreak ? PomodoroState.longBreak : PomodoroState.shortBreak,
        totalSeconds: isLongBreak ? _longBreakDuration : _shortBreakDuration,
        secondsRemaining: isLongBreak ? _longBreakDuration : _shortBreakDuration,
        status: TimerStatus.idle,
      );
    } else {
      state = state.copyWith(
        currentState: PomodoroState.focus,
        totalSeconds: _focusDuration,
        secondsRemaining: _focusDuration,
        status: TimerStatus.idle,
      );
    }
  }

  void toggleTimer() {
    if (state.status == TimerStatus.running) {
      _timer?.cancel();
      state = state.copyWith(status: TimerStatus.paused);
    } else {
      state = state.copyWith(status: TimerStatus.running);
      _startTimer();
    }
  }

  void resetTimer() {
    _timer?.cancel();
    int duration;
    switch (state.currentState) {
      case PomodoroState.focus:
        duration = _focusDuration;
        break;
      case PomodoroState.shortBreak:
        duration = _shortBreakDuration;
        break;
      case PomodoroState.longBreak:
        duration = _longBreakDuration;
        break;
    }
    state = state.copyWith(
      secondsRemaining: duration,
      totalSeconds: duration,
      status: TimerStatus.idle,
    );
  }

  void skipSession() {
    _timer?.cancel();
    _onSessionComplete();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroSession>((ref) {
  return PomodoroNotifier();
});

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(pomodoroProvider);
    final progress = session.totalSeconds > 0 
        ? 1.0 - (session.secondsRemaining / session.totalSeconds)
        : 0.0;
    final minutes = (session.secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (session.secondsRemaining % 60).toString().padLeft(2, '0');

    String stateLabel;
    Color stateColor;
    switch (session.currentState) {
      case PomodoroState.focus:
        stateLabel = 'Focus';
        stateColor = theme.colorScheme.primary;
        break;
      case PomodoroState.shortBreak:
        stateLabel = 'Short Break';
        stateColor = Colors.green;
        break;
      case PomodoroState.longBreak:
        stateLabel = 'Long Break';
        stateColor = Colors.blue;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green.shade400),
                const SizedBox(width: 4),
                Text('${session.completedPomodoros}', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // State indicator
            GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: stateColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        stateLabel,
                        style: TextStyle(
                          color: stateColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Timer circle
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(stateColor),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$minutes:$seconds',
                                  style: theme.textTheme.displayMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  session.status == TimerStatus.running 
                                      ? 'Running...' 
                                      : session.status == TimerStatus.paused 
                                          ? 'Paused' 
                                          : 'Ready',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: () => ref.read(pomodoroProvider.notifier).resetTimer(),
                          icon: const Icon(Icons.refresh),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        const SizedBox(width: 16),
                        FloatingActionButton.large(
                          onPressed: () => ref.read(pomodoroProvider.notifier).toggleTimer(),
                          child: Icon(
                            session.status == TimerStatus.running 
                                ? Icons.pause 
                                : Icons.play_arrow,
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton.filled(
                          onPressed: () => ref.read(pomodoroProvider.notifier).skipSession(),
                          icon: const Icon(Icons.skip_next),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              '${session.completedPomodoros}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: stateColor,
                              ),
                            ),
                            const Text('Pomodoros', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              '${session.completedPomodoros ~/ 4}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Text('Cycles', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              '${session.completedPomodoros * 25}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text('Minutes', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}