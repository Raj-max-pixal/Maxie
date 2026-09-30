import 'package:flutter/material.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';

class AnimatedCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GlassCard(padding: padding, onTap: onTap, child: child);
  }
}
