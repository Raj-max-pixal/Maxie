import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/theme/app_colors.dart';

class MaxieCompanionView extends StatelessWidget {
  const MaxieCompanionView({
    super.key,
    this.state = CompanionPresence.idle,
    this.size = 170,
  });

  final CompanionPresence state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = _styleForState(state);
    return Semantics(
      label: 'MAXie companion is ${state.name}',
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
                  width: size * 0.92,
                  height: size * 0.92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        style.glow.withValues(alpha: 0.58),
                        style.accent.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1.08, 1.08),
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                ),
            Container(
              width: size * 0.62,
              height: size * 0.56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [style.bodyStart, style.bodyEnd],
                ),
                boxShadow: [
                  BoxShadow(
                    color: style.glow.withValues(alpha: 0.55),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: size * 0.17,
                    child: Container(
                      width: size * 0.34,
                      height: size * 0.05,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFF9DECF9), width: 2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: size * 0.13,
                    child: Container(
                      width: size * 0.38,
                      height: size * 0.18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2540).withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(size * 0.08),
                        border: Border.all(color: const Color(0xFF94F2FF)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _Eye(size: size),
                          _Eye(size: size),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveY(
                  begin: -style.floatDistance,
                  end: style.floatDistance,
                  duration: style.duration,
                  curve: Curves.easeInOut,
                ),
          ],
        ),
      ),
    );
  }
}

_CompanionVisualStyle _styleForState(CompanionPresence state) {
  return switch (state) {
    CompanionPresence.happy => const _CompanionVisualStyle(
        glow: AppColors.calmTeal,
        accent: Color(0xFF67E8F9),
        bodyStart: Color(0xFF14B8A6),
        bodyEnd: Color(0xFF7C3AED),
        floatDistance: 7,
        duration: Duration(milliseconds: 1300),
      ),
    CompanionPresence.excited ||
    CompanionPresence.celebrating ||
    CompanionPresence.dancing =>
      const _CompanionVisualStyle(
        glow: AppColors.warmCoral,
        accent: Color(0xFFFDE68A),
        bodyStart: Color(0xFFF97316),
        bodyEnd: Color(0xFF7C3AED),
        floatDistance: 10,
        duration: Duration(milliseconds: 900),
      ),
    CompanionPresence.sleeping => const _CompanionVisualStyle(
        glow: Color(0xFF818CF8),
        accent: Color(0xFFC4B5FD),
        bodyStart: Color(0xFF4338CA),
        bodyEnd: Color(0xFF0F172A),
        floatDistance: 3,
        duration: Duration(milliseconds: 2300),
      ),
    CompanionPresence.thinking || CompanionPresence.listening =>
      const _CompanionVisualStyle(
        glow: AppColors.warning,
        accent: Color(0xFFFDE68A),
        bodyStart: Color(0xFF06B6D4),
        bodyEnd: Color(0xFF7C3AED),
        floatDistance: 5,
        duration: Duration(milliseconds: 1600),
      ),
    _ => const _CompanionVisualStyle(
        glow: AppColors.seed,
        accent: AppColors.calmTeal,
        bodyStart: Color(0xFF7C3AED),
        bodyEnd: Color(0xFF06B6D4),
        floatDistance: 5,
        duration: Duration(milliseconds: 1500),
      ),
  };
}

class _CompanionVisualStyle {
  const _CompanionVisualStyle({
    required this.glow,
    required this.accent,
    required this.bodyStart,
    required this.bodyEnd,
    required this.floatDistance,
    required this.duration,
  });

  final Color glow;
  final Color accent;
  final Color bodyStart;
  final Color bodyEnd;
  final double floatDistance;
  final Duration duration;
}

class _Eye extends StatelessWidget {
  const _Eye({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.055,
      height: size * 0.055,
      decoration: const BoxDecoration(
        color: Color(0xFF67E8F9),
        shape: BoxShape.circle,
      ),
    );
  }
}
