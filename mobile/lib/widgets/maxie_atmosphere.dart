import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:maxie_mobile/theme/app_colors.dart';

/// Animated cosmic backdrop: gradient field + drifting glow orbs.
class MaxieAtmosphere extends StatelessWidget {
  const MaxieAtmosphere({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF070714),
                  Color(0xFF14082C),
                  Color(0xFF06131F),
                  Color(0xFF0A0A16),
                ],
                stops: [0, 0.38, 0.72, 1],
              ),
            ),
          ),
          const Positioned(
            top: -90,
            right: -50,
            child: _GlowOrb(color: AppColors.seed, size: 300),
          ),
          const Positioned(
            top: 180,
            left: -110,
            child: _GlowOrb(color: AppColors.calmTeal, size: 240),
          ),
          const Positioned(
            bottom: 80,
            right: -70,
            child: _GlowOrb(color: AppColors.warmCoral, size: 220),
          ),
          Positioned(
            top: 90,
            left: 40,
            child: const _Spark(size: 6)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(begin: 0.15, end: 0.9, duration: 1600.ms)
                .moveY(begin: 0, end: -18, duration: 2800.ms),
          ),
          Positioned(
            top: 240,
            right: 48,
            child: const _Spark(size: 5)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(begin: 0.1, end: 0.8, duration: 2100.ms)
                .moveY(begin: 0, end: 14, duration: 3200.ms),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.42),
                color.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.12, 1.12),
          duration: 5400.ms,
          curve: Curves.easeInOut,
        )
        .move(
          begin: Offset.zero,
          end: const Offset(-18, 22),
          duration: 7000.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _Spark extends StatelessWidget {
  const _Spark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.85),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.55),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}
