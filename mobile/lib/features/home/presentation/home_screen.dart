import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/content_cards.dart';
import 'package:maxie_mobile/widgets/maxie_companion_view.dart';
import 'package:maxie_mobile/widgets/metric_widgets.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/primary_button.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.now();

    return PremiumScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.calmTeal.withValues(alpha: 0.18),
                child: const Icon(Icons.auto_awesome_rounded, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning, Alex',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFFE9D5FF),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${_weekday(date)}, ${date.day} ${_month(date)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'MAXie',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF93C5FD),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 260.ms).slideY(begin: -0.1, end: 0),
          const SizedBox(height: AppSpacing.xl),
          PremiumCard(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
            glowColor: AppColors.calmTeal,
            child: Column(
              children: [
                const MaxieCompanionView(
                  state: CompanionPresence.happy,
                  size: 190,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF202A3D),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'How can I help you today?',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 360.ms).scale(begin: const Offset(0.96, 0.96)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'New Chat',
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () => context.go(AppRoutes.aiChat),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.document_scanner_rounded),
                  label: const Text('Scan File'),
                ),
              ),
            ],
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
                label: 'Daily Streak',
                value: '12 days',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.warning,
              ),
              StatCard(
                label: 'XP Earned',
                value: '2,840',
                icon: Icons.bolt_rounded,
                color: AppColors.warmCoral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(
            title: "Today's Summary",
            subtitle: 'A calm snapshot of what matters now.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const TaskCard(
            title: '3 high-priority meetings scheduled',
            subtitle: 'MAXie will help you prepare context.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const TaskCard(
            title: 'Draft for Project Nebula is ready',
            subtitle: 'Review it when you have a clear moment.',
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(title: 'Memory Preview'),
          const SizedBox(height: AppSpacing.sm),
          const MemoryCard(
            title: 'You prefer morning planning',
            subtitle: 'Pinned from your companion setup.',
            isPinned: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumCard(
            glowColor: AppColors.seed,
            child: Text(
              '"Small steps still count. I will keep track with you."',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFFE9D5FF),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekday(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  String _month(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[date.month - 1];
  }
}
