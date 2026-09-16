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
    return Semantics(
      label: 'MAXie companion is ${state.name}',
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
                  width: size * 0.98,
                  height: size * 0.98,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .rotate(duration: 18.seconds, begin: 0, end: 1),
            Container(
                  width: size * 0.92,
                  height: size * 0.92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.seed.withValues(alpha: 0.62),
                        AppColors.calmTeal.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.12, 1.12),
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                ),
            Positioned(
              top: size * 0.08,
              right: size * 0.12,
              child: const _Sparkle()
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(begin: 0.2, end: 1, duration: 900.ms)
                  .scale(begin: const Offset(0.6, 0.6), end: const Offset(1.2, 1.2)),
            ),
            Positioned(
              bottom: size * 0.16,
              left: size * 0.1,
              child: const _Sparkle()
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(begin: 0.1, end: 0.85, duration: 1400.ms),
            ),
            Container(
                  width: size * 0.64,
                  height: size * 0.58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size * 0.2),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFA78BFA),
                        Color(0xFF7C3AED),
                        Color(0xFF06B6D4),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.seed.withValues(alpha: 0.62),
                        blurRadius: 32,
                      ),
                      BoxShadow(
                        color: AppColors.calmTeal.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
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
                            border: Border.all(
                              color: const Color(0xFF9DECF9),
                              width: 2,
                            ),
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
                  begin: -8,
                  end: 7,
                  duration: 1600.ms,
                  curve: Curves.easeInOut,
                )
                .rotate(begin: -0.02, end: 0.02, duration: 2200.ms),
          ],
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFFDE68A));
  }
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
            boxShadow: [
              BoxShadow(color: Color(0xFF67E8F9), blurRadius: 8),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.25, 0.55),
          duration: 2400.ms,
          delay: 900.ms,
        );
  }
}
