import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../providers/maxie_state_provider.dart';

class MaxieCharacter extends ConsumerWidget {
  const MaxieCharacter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxieState = ref.watch(maxieStateProvider);
    final animation = _getAnimationForState(maxieState.currentEmotion, maxieState.currentActivity);

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
          child: Lottie.asset(
            animation,
            animate: true,
            repeat: true,
            frameRate: FrameRate(60),
          ),
        ),
      ),
    );
  }

  String _getAnimationForState(String emotion, String activity) {
    // Return appropriate Lottie animation based on emotion and activity
    switch (emotion) {
      case 'happy':
        return 'assets/lottie/maxie_happy.json';
      case 'sleepy':
        return 'assets/lottie/maxie_sleepy.json';
      case 'excited':
        return 'assets/lottie/maxie_excited.json';
      case 'sad':
        return 'assets/lottie/maxie_sad.json';
      case 'focused':
        return 'assets/lottie/maxie_focused.json';
      default:
        return 'assets/lottie/maxie_idle.json';
    }
  }
}
