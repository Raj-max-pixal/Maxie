import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';

enum PremiumCardStyle { glass, neu }

class PremiumCard extends StatefulWidget {
  const PremiumCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.glowColor,
    this.style = PremiumCardStyle.glass,
    this.float = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? glowColor;
  final PremiumCardStyle style;
  final bool float;

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final glow = widget.glowColor ?? AppColors.seed;
    final radius = BorderRadius.circular(24);

    Widget surface = widget.style == PremiumCardStyle.neu
        ? _NeuSurface(glow: glow, radius: radius, padding: widget.padding, child: widget.child)
        : _GlassSurface(glow: glow, radius: radius, padding: widget.padding, child: widget.child);

    surface = AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: 160.ms,
      curve: Curves.easeOutCubic,
      child: surface,
    );

    if (widget.float) {
      surface = surface
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: -3, end: 5, duration: 2600.ms, curve: Curves.easeInOut);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: widget.onTap,
        onHighlightChanged: (value) => setState(() => _pressed = value),
        child: surface,
      ),
    );
  }
}

class _GlassSurface extends StatelessWidget {
  const _GlassSurface({
    required this.glow,
    required this.radius,
    required this.padding,
    required this.child,
  });

  final Color glow;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.26),
            blurRadius: 34,
            spreadRadius: 1,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.58),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AppColors.glassEdge),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.07),
                  glow.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      gradient: RadialGradient(
                        center: const Alignment(-0.8, -0.95),
                        radius: 1.1,
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -40,
                  right: -12,
                  child: IgnorePointer(
                    child: Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            glow.withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NeuSurface extends StatelessWidget {
  const _NeuSurface({
    required this.glow,
    required this.radius,
    required this.padding,
    required this.child,
  });

  final Color glow;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.panelTop, AppColors.panelBottom],
        ),
        border: Border.all(color: glow.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.68),
            blurRadius: 18,
            offset: const Offset(10, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(-6, -6),
          ),
          BoxShadow(
            color: glow.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.22),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
