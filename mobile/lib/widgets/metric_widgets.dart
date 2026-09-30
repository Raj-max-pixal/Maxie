import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';

class XpProgressCard extends StatelessWidget {
  const XpProgressCard({
    required this.level,
    required this.progress,
    this.xpLabel,
    super.key,
  });

  final int level;
  final double progress;
  final String? xpLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumCard(
      glowColor: AppColors.calmTeal,
      float: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: AppColors.warmCoral, size: 20),
              const SizedBox(width: 8),
              Text(
                'Friendship Level $level',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  color: AppColors.calmTeal,
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: 2200.ms,
                color: Colors.white24,
              ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            xpLabel ?? '${(progress * 100).round()}% to the next level',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
    this.color = AppColors.seed,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      style: PremiumCardStyle.neu,
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.16),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 12),
              ],
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
