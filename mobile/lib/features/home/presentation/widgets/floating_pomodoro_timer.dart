import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maxie_mobile/features/home/presentation/providers/overlay_provider.dart';
import 'package:maxie_mobile/features/study/domain/services/study_mode.dart';

class FloatingPomodoroTimer extends ConsumerWidget {
  const FloatingPomodoroTimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayState = ref.watch(overlayProvider);
    final studyMode = ref.watch(studyModeProvider);
    final widget = overlayState.getWidget('pomodoro_timer');
    
    if (widget == null || !widget.isVisible || !studyMode.isRunning) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          ref.read(overlayProvider.notifier).updateWidgetPosition(
            'pomodoro_timer',
            Offset(widget.position.dx + details.delta.dx, widget.position.dy + details.delta.dy),
          );
        },
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: overlayState.transparency),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.timer,
                size: 32,
                color: Colors.purple,
              ),
              const SizedBox(height: 8),
              Text(
                studyMode.formattedTime,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Session ${studyMode.completedSessions + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
