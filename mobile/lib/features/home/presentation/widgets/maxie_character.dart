import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/maxie_state_provider.dart';

class MaxieCharacter extends ConsumerWidget {
  const MaxieCharacter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxieState = ref.watch(maxieStateProvider);
    final visual = _getVisualForState(maxieState.currentEmotion);

    return GestureDetector(
      onTap: () {
        ref.read(maxieStateProvider.notifier).handleTap();
      },
      onDoubleTap: () {
        ref.read(maxieStateProvider.notifier).handleDoubleTap();
      },
      onLongPress: () {
        ref.read(maxieStateProvider.notifier).handleLongPress();
      },
      child: Center(
        child: SizedBox(
          height: 200,
          width: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  visual.color.withValues(alpha: 0.85),
                  Colors.deepPurple.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: visual.color.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                visual.icon,
                size: 96,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  ({IconData icon, Color color}) _getVisualForState(String emotion) {
    switch (emotion) {
      case 'happy':
        return (icon: Icons.sentiment_very_satisfied, color: Colors.pink);
      case 'sleepy':
        return (icon: Icons.bedtime, color: Colors.indigo);
      case 'excited':
        return (icon: Icons.celebration, color: Colors.orange);
      case 'sad':
        return (icon: Icons.sentiment_dissatisfied, color: Colors.blueGrey);
      case 'focused':
        return (icon: Icons.psychology, color: Colors.teal);
      default:
        return (icon: Icons.pets, color: Colors.deepPurple);
    }
  }
}
