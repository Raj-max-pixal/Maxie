import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/features/memory/application/memory_manager.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/pet/application/pet_controller.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';
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
    final memoryState = ref.watch(memoryManagerProvider);
    final petAsync = ref.watch(petControllerProvider);
    final greeting = _timeGreeting(date, memoryState.memories);
    final latestMemory = _latestMemory(memoryState.memories);
    final summary = memoryState.summary;

    return PremiumScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.calmTeal.withValues(alpha: 0.16),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _smartGreetingTitle(greeting.title, summary),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFFF5E9FF),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      _smartGreetingDetail(date, summary, latestMemory),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              const _StatusCapsule(
                label: 'LIVE',
                icon: Icons.bolt_rounded,
                color: AppColors.warning,
              ),
            ],
          ).animate().fadeIn(duration: 260.ms).slideY(begin: -0.1, end: 0),
          const SizedBox(height: AppSpacing.lg),
          _HeroSpotlight(
            greeting: greeting,
            summary: summary,
            latestMemory: latestMemory,
            onMissionTap: () => context.push(AppRoutes.missionControl),
            onChatTap: () => context.go(AppRoutes.aiChat),
          ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.06, end: 0),
          const SizedBox(height: AppSpacing.lg),
          petAsync.when(
            loading: () => const PremiumCard(child: LinearProgressIndicator()),
            error: (error, stackTrace) => PremiumCard(
              child: Text('MAXie is taking a moment to reconnect.'),
            ),
            data: (pet) => _HomePetPanel(
              pet: pet,
              onAction: (action) =>
                  ref.read(petControllerProvider.notifier).perform(action),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(
            title: 'Command Deck',
            subtitle: 'Fast entry points for the parts of MAXie you use most.',
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.16,
            children: [
              _FeatureActionCard(
                title: 'Chat Core',
                subtitle: 'Stream answers, context, and memory-aware help.',
                icon: Icons.chat_bubble_rounded,
                color: AppColors.seed,
                onTap: () => context.go(AppRoutes.aiChat),
              ),
              _FeatureActionCard(
                title: 'Memory Brain',
                subtitle: 'Inspect what MAXie keeps and what matters most.',
                icon: Icons.psychology_rounded,
                color: AppColors.calmTeal,
                onTap: () => context.go(AppRoutes.memory),
              ),
              _FeatureActionCard(
                title: 'Agent Run',
                subtitle: 'Plan, verify, and review MAXie’s live mobile state.',
                icon: Icons.precision_manufacturing_rounded,
                color: AppColors.electricBlue,
                onTap: () => context.push(AppRoutes.agentRun),
              ),
              _FeatureActionCard(
                title: 'Pet State',
                subtitle: 'Feed, react, and grow friendship through actions.',
                icon: Icons.favorite_rounded,
                color: AppColors.warmCoral,
                onTap: () => context.go(AppRoutes.pet),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _TodaysCompanionCard(now: date, memories: memoryState.memories),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Launch Chat',
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () => context.go(AppRoutes.aiChat),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showFoundationMessage(
                    context,
                    'Voice mode can be enabled from Settings.',
                  ),
                  icon: const Icon(Icons.mic_rounded),
                  label: const Text('Voice Mode'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          petAsync.maybeWhen(
            data: (pet) => XpProgressCard(
              level: pet.level,
              progress: pet.xpProgress,
              xpLabel: '${pet.xp % 100}/100 XP to level ${pet.level + 1}',
            ),
            orElse: () => const SizedBox.shrink(),
          ),
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
            title: 'Live Pulse',
            subtitle: 'The relationship layer behind MAXie right now.',
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.18,
            children: [
              _PulseCard(
                label: 'Memories',
                value: '${summary.totalMemories}',
                detail: 'Stored context points',
                icon: Icons.layers_rounded,
                color: AppColors.calmTeal,
              ),
              _PulseCard(
                label: 'Friendship',
                value: '${summary.relationshipLevel}',
                detail: 'Bond intensity',
                icon: Icons.favorite_rounded,
                color: AppColors.warmCoral,
              ),
              _PulseCard(
                label: 'Tasks Ready',
                value: '04',
                detail: 'Focus missions queued',
                icon: Icons.dashboard_customize_rounded,
                color: AppColors.electricBlue,
              ),
              _PulseCard(
                label: 'Aura',
                value: _companionMood(date).label,
                detail: 'Current simulated mood',
                icon: Icons.auto_awesome_rounded,
                color: AppColors.softLilac,
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
          if (latestMemory != null)
            PremiumCard(
              glowColor: AppColors.calmTeal,
              float: true,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.calmTeal,
                ),
                title: Text('You recently shared ${latestMemory.title}'),
                subtitle: Text(latestMemory.value),
              ),
            ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.06, end: 0),
          if (latestMemory != null) const SizedBox(height: AppSpacing.lg),
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

  MemoryModel? _latestMemory(List<MemoryModel> memories) {
    if (memories.isEmpty) {
      return null;
    }
    final sorted = [...memories]
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
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
    MemoryModel? latestMemory,
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
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

class _TodaysCompanionCard extends StatelessWidget {
  const _TodaysCompanionCard({required this.now, required this.memories});

  final DateTime now;
  final List<MemoryModel> memories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _timeGreeting(now, memories);
    final mood = _companionMood(now);
    final message = _rotatingCompanionMessage(now, memories);

    return PremiumCard(
      glowColor: AppColors.warmCoral,
      float: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Today's Companion",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              const _StatusCapsule(
                label: 'AURA',
                icon: Icons.blur_on_rounded,
                color: AppColors.warmCoral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              final info = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CompanionLine(icon: greeting.icon, text: greeting.title),
                  _CompanionLine(
                    icon: greeting.detailIcon,
                    text: greeting.detail,
                  ),
                  const _CompanionLine(
                    icon: '\u{2728}',
                    text: 'You completed 3 tasks today.',
                  ),
                  const _CompanionLine(
                    icon: '\u{1F49C}',
                    text: 'Friendship Level 12',
                  ),
                  _CompanionLine(
                    icon: mood.icon,
                    text: 'Companion Mood: ${mood.label}',
                  ),
                  _CompanionLine(icon: '\u{1F4AC}', text: message),
                ],
              );

              final avatar = Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.warmCoral.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: MaxieCompanionView(
                  state: _presenceForCompanionMood(mood.label),
                  size: compact ? 120 : 152,
                ),
              );

              if (compact) {
                return Column(
                  children: [
                    avatar,
                    const SizedBox(height: AppSpacing.sm),
                    info,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: info),
                  const SizedBox(width: AppSpacing.md),
                  avatar,
                ],
              );
            },
          ),
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
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
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
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _HeroSpotlight extends StatelessWidget {
  const _HeroSpotlight({
    required this.greeting,
    required this.summary,
    required this.latestMemory,
    required this.onMissionTap,
    required this.onChatTap,
  });

  final _CompanionGreeting greeting;
  final MemorySummary summary;
  final MemoryModel? latestMemory;
  final VoidCallback onMissionTap;
  final VoidCallback onChatTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumCard(
      glowColor: AppColors.seed,
      float: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;
          final content = [
            Expanded(
              flex: compact ? 0 : 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _StatusCapsule(
                        label: 'PHASE 03',
                        icon: Icons.rocket_launch_rounded,
                        color: AppColors.electricBlue,
                      ),
                      _StatusCapsule(
                        label: '${summary.totalMemories} MEMORIES',
                        icon: Icons.psychology_rounded,
                        color: AppColors.calmTeal,
                      ),
                      _StatusCapsule(
                        label: 'REL ${summary.relationshipLevel}',
                        icon: Icons.favorite_rounded,
                        color: AppColors.warmCoral,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'MAXie is evolving into a living companion interface.',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      color: const Color(0xFFF8FAFF),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    latestMemory == null
                        ? greeting.detail
                        : 'Latest signal: ${latestMemory!.title}. ${greeting.detail}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: 'Open Mission',
                          icon: Icons.rocket_launch_rounded,
                          onPressed: onMissionTap,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onChatTap,
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          label: const Text('Talk to MAXie'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _OrbitMetric(
                        label: 'XP',
                        value: '2.8k',
                        color: AppColors.warning,
                      ),
                      _OrbitMetric(
                        label: 'Mood',
                        value: 'Curious',
                        color: AppColors.softLilac,
                      ),
                      _OrbitMetric(
                        label: 'Focus',
                        value: 'Stable',
                        color: AppColors.aurora,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!compact) const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: compact ? 0 : 5,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.seed.withValues(alpha: 0.16),
                      AppColors.calmTeal.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MaxieCompanionView(
                      state: CompanionPresence.excited,
                      size: 168,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      greeting.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Animated actions, floating presence, and richer depth are now the visual direction.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];

          return compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    content.first,
                    const SizedBox(height: AppSpacing.md),
                    content.last,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: content,
                );
        },
      ),
    );
  }
}

class _StatusCapsule extends StatelessWidget {
  const _StatusCapsule({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 18),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitMetric extends StatelessWidget {
  const _OrbitMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class _FeatureActionCard extends StatelessWidget {
  const _FeatureActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      glowColor: color,
      float: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.28),
                  color.withValues(alpha: 0.12),
                ],
              ),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.24), blurRadius: 16),
              ],
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const Spacer(),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomePetPanel extends StatelessWidget {
  const _HomePetPanel({required this.pet, required this.onAction});

  final PetState pet;
  final Future<void> Function(PetAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PremiumCard(
      glowColor: AppColors.warmCoral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: AppColors.warmCoral),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${pet.name} is ${pet.mood.name}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text('Lv ${pet.level}', style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(pet.recentInteraction, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _HomeStat(label: 'Energy', value: pet.energy),
              ),
              Expanded(
                child: _HomeStat(label: 'Hunger', value: pet.hunger),
              ),
              Expanded(
                child: _HomeStat(label: 'Happy', value: pet.happiness),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _HomeAction(
                label: 'Feed',
                icon: Icons.restaurant_rounded,
                onTap: () => onAction(PetAction.feed),
              ),
              _HomeAction(
                label: 'Play',
                icon: Icons.sports_esports_rounded,
                onTap: () => onAction(PetAction.play),
              ),
              _HomeAction(
                label: 'Sleep',
                icon: Icons.bedtime_rounded,
                onTap: () => onAction(PetAction.sleep),
              ),
              _HomeAction(
                label: 'Dance',
                icon: Icons.music_note_rounded,
                onTap: () => onAction(PetAction.dance),
              ),
              _HomeAction(
                label: 'Listen',
                icon: Icons.hearing_rounded,
                onTap: () => onAction(PetAction.listen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeStat extends StatelessWidget {
  const _HomeStat({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(
          '${value.round()}%',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 17),
    label: Text(label),
  );
}

class _PulseCard extends StatelessWidget {
  const _PulseCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String detail;
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
          Icon(icon, color: color),
          const Spacer(),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

_CompanionGreeting _timeGreeting(DateTime now, List<MemoryModel> memories) {
  final hour = now.hour;

  // Find interesting memories to include in the greeting
  final projects =
      memories.where((m) => m.category == MemoryCategory.projects).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  final dreams = memories
      .where((m) => m.category == MemoryCategory.dreamCompanies)
      .toList();

  String title = 'Good Morning Raj';
  String icon = '☀️';
  String detail = "Today's mission awaits.";
  String detailIcon = '🎯';

  if (hour >= 5 && hour < 12) {
    title = 'Good Morning Raj';
    icon = '☀️';
    if (projects.isNotEmpty) {
      final p = projects.first;
      if (now.difference(p.updatedAt).inDays <= 2) {
        detail = 'Yesterday you worked on ${p.value}. Ready to continue?';
      } else {
        detail = 'Let\'s make progress on ${p.value} today.';
      }
    }
  } else if (hour >= 12 && hour < 17) {
    title = 'Good Afternoon Raj';
    icon = '🌤️';
    detailIcon = '✅';
    detail = "Let's finish today's goals.";
    if (dreams.isNotEmpty) {
      detail = 'Every step brings you closer to ${dreams.first.value}.';
    }
  } else if (hour >= 17 && hour < 22) {
    title = 'Good Evening Raj';
    icon = '🌙';
    detailIcon = '💜';
    detail = "You're doing great today.";
    if (dreams.isNotEmpty) {
      detail =
          "You're getting closer to your ${dreams.first.value} dream. Let's continue today's mission.";
    }
  } else {
    title = 'Good Night Raj';
    icon = '😴';
    detailIcon = '🛌';
    detail = "Don't forget to rest. We'll continue tomorrow.";
  }

  return _CompanionGreeting(
    icon: icon,
    title: title,
    detailIcon: detailIcon,
    detail: detail,
  );
}

String _rotatingCompanionMessage(DateTime now, List<MemoryModel> memories) {
  final messages = [
    "You've got this 💜",
    "I'm always here.",
    'Ready to build something amazing?',
    "Today's a good day to learn.",
  ];
  final goals = memories
      .where((m) => m.category == MemoryCategory.goals)
      .toList();
  if (goals.isNotEmpty) {
    messages.add("Let's focus on: ${goals.first.value}");
  }
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

CompanionPresence _presenceForCompanionMood(String mood) {
  switch (mood.toLowerCase()) {
    case 'happy':
    case 'celebrating':
    case 'motivating':
      return CompanionPresence.excited;
    case 'thinking':
    case 'study mode':
      return CompanionPresence.thinking;
    case 'sleeping':
      return CompanionPresence.sleeping;
    case 'vibing':
      return CompanionPresence.dancing;
    default:
      return CompanionPresence.happy;
  }
}
