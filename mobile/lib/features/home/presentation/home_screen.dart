import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/features/memory/application/memory_providers.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final date = DateTime.now();
    final greeting = _timeGreeting(date);
    final memoryState = ref.watch(memoryManagerProvider);
    final latestMemory = _latestMemory(memoryState.memories);
    final summary = memoryState.summary;

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
                      _smartGreetingTitle(greeting.title, summary),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFFE9D5FF),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      _smartGreetingDetail(date, summary, latestMemory),
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
          _TodaysCompanionCard(now: date),
          const SizedBox(height: AppSpacing.lg),
          if (latestMemory != null)
            PremiumCard(
              glowColor: AppColors.calmTeal,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.psychology_rounded, color: AppColors.calmTeal),
                title: Text('You recently shared ${latestMemory.title}'),
                subtitle: Text(latestMemory.value),
              ),
            ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.06, end: 0),
          if (latestMemory != null) const SizedBox(height: AppSpacing.lg),
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
                    _rotatingCompanionMessage(date),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 360.ms).scale(
                begin: const Offset(0.96, 0.96),
              ),
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
                  onPressed: () => _showFoundationMessage(
                    context,
                    'Scan file foundation is ready for Phase 3.',
                  ),
                  icon: const Icon(Icons.document_scanner_rounded),
                  label: const Text('Scan File'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(
            title: 'Quick Actions',
            subtitle: 'Your core entry points into MAXie.',
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.88,
            children: [
              _QuickAction(
                label: 'Chat',
                icon: Icons.chat_bubble_rounded,
                color: AppColors.seed,
                onTap: () => context.go(AppRoutes.aiChat),
              ),
              _QuickAction(
                label: 'Memory',
                icon: Icons.psychology_rounded,
                color: AppColors.calmTeal,
                onTap: () => context.go(AppRoutes.memory),
              ),
              _QuickAction(
                label: 'Voice',
                icon: Icons.mic_rounded,
                color: AppColors.warmCoral,
                onTap: () => _showFoundationMessage(
                  context,
                  'Voice mode is ready as a Phase 3 entry point.',
                ),
              ),
              _QuickAction(
                label: 'Tasks',
                icon: Icons.calendar_month_rounded,
                color: AppColors.warning,
                onTap: () => context.go(AppRoutes.tasks),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const XpProgressCard(level: 12, progress: 0.72),
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
                value: '7 days',
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

  MemoryRecord? _latestMemory(List<MemoryRecord> memories) {
    if (memories.isEmpty) {
      return null;
    }
    final sorted = [...memories]..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return sorted.first;
  }

  String _smartGreetingTitle(String fallback, MemorySummary summary) {
    if (summary.totalMemories == 0) {
      return fallback;
    }
    if (summary.relationshipLevel >= 20) {
      return 'Welcome back, MAXie remembers a lot about you';
    }
    return '$fallback - MAXie is learning you well';
  }

  String _smartGreetingDetail(
    DateTime date,
    MemorySummary summary,
    MemoryRecord? latestMemory,
  ) {
    final base = '${_weekday(date)}, ${date.day} ${_month(date)}';
    if (latestMemory == null) {
      return base;
    }
    if (latestMemory.category == MemoryCategory.projects) {
      return '$base · Yesterday you worked on ${latestMemory.title}.';
    }
    if (summary.relationshipLevel >= 18) {
      return '$base · You and MAXie have shared ${summary.totalMemories} memories.';
    }
    return '$base · Last time you mentioned ${latestMemory.title}.';
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

  void _showFoundationMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _TodaysCompanionCard extends StatelessWidget {
  const _TodaysCompanionCard({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _timeGreeting(now);
    final mood = _companionMood(now);
    final message = _rotatingCompanionMessage(now);

    return PremiumCard(
      glowColor: AppColors.warmCoral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Companion",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _CompanionLine(icon: greeting.icon, text: greeting.title),
          _CompanionLine(icon: greeting.detailIcon, text: greeting.detail),
          const _CompanionLine(
            icon: '\u{2728}',
            text: 'You completed 3 tasks today.',
          ),
          const _CompanionLine(icon: '\u{1F525}', text: '7 day streak'),
          const _CompanionLine(icon: '\u{1F49C}', text: 'Friendship Level 12'),
          const _CompanionLine(
            icon: '\u{1F381}',
            text: 'Daily Reward Available',
          ),
          _CompanionLine(icon: mood.icon, text: 'Companion Mood: ${mood.label}'),
          _CompanionLine(icon: '\u{1F4AC}', text: message),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0);
  }
}

class _CompanionLine extends StatelessWidget {
  const _CompanionLine({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      glowColor: color,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

_CompanionGreeting _timeGreeting(DateTime now) {
  final hour = now.hour;
  if (hour >= 5 && hour < 12) {
    return const _CompanionGreeting(
      icon: '\u{2600}\u{FE0F}',
      title: 'Good Morning Raj',
      detailIcon: '\u{1F3AF}',
      detail: "Today's mission awaits.",
    );
  }
  if (hour >= 12 && hour < 17) {
    return const _CompanionGreeting(
      icon: '\u{1F324}',
      title: 'Good Afternoon Raj',
      detailIcon: '\u{2705}',
      detail: "Let's finish today's goals.",
    );
  }
  if (hour >= 17 && hour < 22) {
    return const _CompanionGreeting(
      icon: '\u{1F306}',
      title: 'Good Evening Raj',
      detailIcon: '\u{1F49C}',
      detail: "You're doing great today.",
    );
  }
  return const _CompanionGreeting(
    icon: '\u{1F319}',
    title: 'Good Night Raj',
    detailIcon: '\u{1F6CC}',
    detail: "Don't forget to recharge yourself too.",
  );
}

String _rotatingCompanionMessage(DateTime now) {
  const messages = [
    "You've got this \u{1F49C}",
    "I'm always here.",
    'Ready to build something amazing?',
    "Today's a good day to learn.",
    "Let's win Shipaton.",
  ];
  return messages[(now.day + now.hour) % messages.length];
}

_CompanionMood _companionMood(DateTime now) {
  const moods = [
    _CompanionMood(icon: '\u{1F60A}', label: 'Happy'),
    _CompanionMood(icon: '\u{1F914}', label: 'Thinking'),
    _CompanionMood(icon: '\u{1F634}', label: 'Sleeping'),
    _CompanionMood(icon: '\u{1F389}', label: 'Celebrating'),
    _CompanionMood(icon: '\u{1F4AA}', label: 'Motivating'),
    _CompanionMood(icon: '\u{1F3B5}', label: 'Vibing'),
    _CompanionMood(icon: '\u{1F4DA}', label: 'Study Mode'),
  ];
  return moods[(now.weekday + now.hour) % moods.length];
}

class _CompanionGreeting {
  const _CompanionGreeting({
    required this.icon,
    required this.title,
    required this.detailIcon,
    required this.detail,
  });

  final String icon;
  final String title;
  final String detailIcon;
  final String detail;
}

class _CompanionMood {
  const _CompanionMood({required this.icon, required this.label});

  final String icon;
  final String label;
}
