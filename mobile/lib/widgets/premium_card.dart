import 'package:flutter/material.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';

enum PremiumCardStyle { neu, flat }

/// A restrained surface shared by every MAXie screen.
class PremiumCard extends StatelessWidget {
  const PremiumCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.glowColor,
    this.float = false,
    this.style = PremiumCardStyle.flat,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? glowColor;
  final bool float;
  final PremiumCardStyle style;

  @override
  Widget build(BuildContext context) {
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF151D29),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: .075)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .22),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: .055),
              blurRadius: 28,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: surface,
      ),
    );
  }
}
