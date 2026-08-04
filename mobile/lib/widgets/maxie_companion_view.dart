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
                  width: size * 0.92,
                  height: size * 0.92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.seed.withValues(alpha: 0.55),
                        AppColors.calmTeal.withValues(alpha: 0.20),
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.seed.withValues(alpha: 0.55),
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
                .moveY(begin: -4, end: 5, duration: 1500.ms, curve: Curves.easeInOut),
          ],
        ),
      ),
    );
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
      ),
    );
  }
}
