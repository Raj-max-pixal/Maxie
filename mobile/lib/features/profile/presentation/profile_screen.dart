import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/content_cards.dart';
import 'package:maxie_mobile/widgets/metric_widgets.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumScaffold(
      title: 'Profile',
      actions: [
        IconButton(
          tooltip: 'Settings',
          onPressed: () => context.go(AppRoutes.settings),
          icon: const Icon(Icons.settings_rounded),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
        children: [
          PremiumCard(
            glowColor: AppColors.seed,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.seed.withValues(alpha: 0.22),
                  child: const Icon(Icons.person_rounded, size: 34),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alex',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Joined Aug 2026',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Chip(label: Text('Lv. 7')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const XpProgressCard(level: 7, progress: 0.68),
          const SizedBox(height: AppSpacing.lg),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.25,
            children: const [
              StatCard(
                label: 'Current Streak',
                value: '12',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.warning,
              ),
              StatCard(
                label: 'Memories',
                value: '24',
                icon: Icons.auto_stories_rounded,
                color: AppColors.calmTeal,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(title: 'Achievements'),
          const SizedBox(height: AppSpacing.sm),
          const AchievementCard(
            title: 'First companion check-in',
            icon: Icons.emoji_events_rounded,
          ),
          const SizedBox(height: AppSpacing.sm),
          const AchievementCard(
            title: 'Seven-day reflection streak',
            icon: Icons.bolt_rounded,
          ),
        ],
      ),
    );
  }
}
