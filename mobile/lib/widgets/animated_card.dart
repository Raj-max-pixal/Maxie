import 'package:flutter/material.dart';
import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';

class AnimatedCard extends StatefulWidget {
  const AnimatedCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: AppConstants.shortAnimation,
      curve: AppConstants.defaultCurve,
      child: Card(
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
