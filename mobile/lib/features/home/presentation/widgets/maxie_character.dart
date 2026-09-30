import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:maxie_mobile/features/home/presentation/providers/maxie_state_provider.dart';
import 'package:maxie_mobile/features/settings/presentation/providers/settings_provider.dart';

class MaxieCharacter extends ConsumerWidget {
  const MaxieCharacter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxieState = ref.watch(maxieStateProvider);
    final settings = ref.watch(settingsProvider);
    final visual = _getVisualForState(maxieState.currentEmotion);

    final double size = 100.0 * settings.maxieSize;

    // Apply animation based on activity
    Widget characterBody = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            visual.color.withOpacity(0.85),
            Colors.deepPurple.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: visual.color.withOpacity(0.35),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          visual.icon,
          size: size * 0.5,
          color: Colors.white,
        ),
      ),
    );

    // Apply walk/wobble animation if walking
    if (maxieState.currentActivity == 'walking') {
      characterBody = characterBody
          .animate(onPlay: (controller) => controller.repeat())
          .shake(hz: 3, curve: Curves.easeInOutBack, rotation: 0.08)
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.96, 1.04),
            duration: 250.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(0.96, 1.04),
            end: const Offset(1.0, 1.0),
            duration: 250.ms,
            curve: Curves.easeInOut,
          );
    } else if (maxieState.currentActivity == 'dragged') {
      // Floating/wiggly animation when flying
      characterBody = characterBody
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .rotate(end: 0.08, duration: 200.ms, curve: Curves.easeInOutSine)
          .scale(end: const Offset(1.08, 0.92), duration: 250.ms, curve: Curves.easeInOutSine);
    } else if (maxieState.isSleeping) {
      // Breathing animation
      characterBody = characterBody
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(end: const Offset(1.0, 0.93), duration: 1500.ms, curve: Curves.easeInOutSine);
    } else {
      // Idle breathing
      characterBody = characterBody
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(end: const Offset(0.98, 1.02), duration: 1000.ms, curve: Curves.easeInOutSine);
    }

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
      onPanUpdate: (details) {
        final currentPos = maxieState.petPosition;
        ref.read(maxieStateProvider.notifier).updatePetDragPosition(
              Offset(currentPos.dx + details.delta.dx, currentPos.dy + details.delta.dy),
            );
      },
      onPanEnd: (_) {
        ref.read(maxieStateProvider.notifier).releaseDrag();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: SizedBox(
          width: size,
          height: size + 20, // leave space for hats
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Character body (placed at the bottom of stack to make hats overlap correctly)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: characterBody,
              ),

              // Accessories layer
              if (maxieState.equippedAccessories.contains('crown'))
                Positioned(
                  top: -size * 0.15,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: Text('👑', style: TextStyle(fontSize: 26)),
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .moveY(end: -2, duration: 1.seconds),
                ),

              if (maxieState.equippedAccessories.contains('detective_hat'))
                Positioned(
                  top: -size * 0.12,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: Text('🕵️‍♂️', style: TextStyle(fontSize: 26)),
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .moveY(end: -2, duration: 1.seconds),
                ),

              if (maxieState.equippedAccessories.contains('wizard_hat'))
                Positioned(
                  top: -size * 0.22,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: Text('🧙', style: TextStyle(fontSize: 28)),
                  ),
                ),

              if (maxieState.equippedAccessories.contains('sunglasses'))
                Positioned(
                  bottom: size * 0.3,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: Text('😎', style: TextStyle(fontSize: 24)),
                  ),
                ),
            ],
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
