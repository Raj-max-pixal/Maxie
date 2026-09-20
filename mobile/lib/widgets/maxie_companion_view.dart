import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/theme/app_colors.dart';

/// The shared companion avatar used across the mobile product.
///
/// Keeping this as a single component means Home, Chat and Pet always show
/// the same MAXie identity instead of different placeholder characters.
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
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
                  width: size * .94,
                  height: size * .94,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.calmTeal.withValues(alpha: .34),
                        AppColors.seed.withValues(alpha: .14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(.92, .92),
                  end: const Offset(1.08, 1.08),
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                ),
            Image.asset(
                  'assets/images/maxie_companion_v1.png',
                  width: size * .9,
                  height: size * .9,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveY(
                  begin: -4,
                  end: 5,
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                ),
          ],
        ),
      ),
    );
  }
}
