import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double blurIntensity;
  final Color? tintColor;
  final VoidCallback? onTap;
  final bool animate3d;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurIntensity = 10,
    this.tintColor,
    this.onTap,
    this.animate3d = true,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _pressed = false;

  BorderRadius get _borderRadius {
    final radius = widget.borderRadius ?? BorderRadius.circular(20);
    return radius is BorderRadius ? radius : BorderRadius.circular(20);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveTint =
        widget.tintColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.7));
    final pressScale = _pressed ? 0.985 : 1.0;

    Widget card = ClipRRect(
      borderRadius: _borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurIntensity,
          sigmaY: widget.blurIntensity,
        ),
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: _borderRadius,
            color: effectiveTint,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.58),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.07),
                blurRadius: widget.blurIntensity + 10,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.18),
                blurRadius: 12,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: _borderRadius,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.12 : 0.28),
                          Colors.transparent,
                          Colors.black.withValues(alpha: isDark ? 0.06 : 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              widget.child,
            ],
          ),
        ),
      ),
    );

    if (widget.animate3d) {
      card = AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_pressed ? -0.018 : 0)
          ..rotateY(_pressed ? 0.018 : 0)
          ..multiply(
            Matrix4.diagonal3Values(pressScale, pressScale, pressScale),
          ),
        child: card,
      );
    }

    return Container(
      margin: widget.margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: widget.animate3d
              ? (value) => setState(() => _pressed = value)
              : null,
          borderRadius: _borderRadius,
          child: card,
        ),
      ),
    );
  }
}
