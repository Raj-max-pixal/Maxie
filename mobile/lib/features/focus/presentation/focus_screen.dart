import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/productivity/presentation/screens/pomodoro_screen.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';

/// A phone-first control surface around the existing Pomodoro state machine.
class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(pomodoroProvider);
    final controller = ref.read(pomodoroProvider.notifier);
    final remaining = session.secondsRemaining;
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    final isRunning = session.status == TimerStatus.running;
    final progress = session.totalSeconds == 0
        ? 0.0
        : 1 - (remaining / session.totalSeconds);
    final mode = switch (session.currentState) {
      PomodoroState.focus => 'Deep work',
      PomodoroState.shortBreak => 'Short break',
      PomodoroState.longBreak => 'Long break',
    };

    return PremiumScaffold(
      title: 'Focus',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 112),
        children: [
          Text(
            mode,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            isRunning
                ? 'MAXie is keeping your session calm and clear.'
                : 'Choose one thing. MAXie will keep you company.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: .62),
            ),
          ),
          const SizedBox(height: 22),
          PremiumCard(
            glowColor: const Color(0xFFB6A3FF),
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: 218,
                  height: 218,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 218,
                        height: 218,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0, 1),
                          strokeWidth: 10,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: .08),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFB6A3FF),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mode.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF9C8BE8),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '$minutes:$seconds',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isRunning ? 'Stay with it' : 'Ready when you are',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: .58),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.resetTimer,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: controller.toggleTimer,
                        icon: Icon(
                          isRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          isRunning ? 'Pause session' : 'Start focus',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _FocusMetric(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Completed',
                  value: '${session.completedPomodoros} sessions',
                  color: const Color(0xFF9CEED1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FocusMetric(
                  icon: Icons.bolt_rounded,
                  label: 'Reward',
                  value: '+25 XP / session',
                  color: const Color(0xFFFFCD89),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PremiumCard(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.nightlight_round,
                color: Color(0xFF9C8BE8),
              ),
              title: const Text('Need a reset?'),
              subtitle: const Text(
                'Skip to a break when you genuinely need one.',
              ),
              trailing: TextButton(
                onPressed: controller.skipSession,
                child: const Text('Take break'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusMetric extends StatelessWidget {
  const _FocusMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => PremiumCard(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: .58),
          ),
        ),
      ],
    ),
  );
}
