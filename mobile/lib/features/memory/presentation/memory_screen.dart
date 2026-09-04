import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/memory/application/memory_manager.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/app_empty_state.dart';
import 'package:maxie_mobile/widgets/app_text_field.dart';
import 'package:maxie_mobile/widgets/loading_indicator.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key});

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen> {
  String _query = '';
  MemoryCategory? _category;

  @override
  Widget build(BuildContext context) {
    final memoriesAsync = ref.watch(memoryBrainListProvider);
    final summaryAsync = ref.watch(memoryBrainSummaryProvider);
    final timelineAsync = ref.watch(memoryBrainTimelineProvider);
    final relationship = ref.watch(relationshipStatsProvider);

    return PremiumScaffold(
      title: 'Memory Brain',
      child: memoriesAsync.when(
        loading: () => const LoadingIndicator(message: 'Opening Memory Brain'),
        error: (error, stackTrace) => AppEmptyState(
          title: 'Memory needs a moment',
          message: error.toString(),
          icon: Icons.psychology_alt_rounded,
        ),
        data: (memories) {
          final filtered = _filter(memories);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
            children: [
              const SectionTitle(
                title: 'Memory Brain',
                subtitle: 'MAXie remembers what matters and grows with you.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _RelationshipPanel(stats: relationship),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Search by keyword, tag, category, date, importance',
                prefixIcon: Icons.search_rounded,
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppSpacing.md),
              _CategoryChips(
                selected: _category,
                onSelected: (category) => setState(() => _category = category),
              ),
              const SizedBox(height: AppSpacing.lg),
              summaryAsync.maybeWhen(
                data: (summary) => _SummaryGrid(summary: summary),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionTitle(title: 'Pinned'),
              const SizedBox(height: AppSpacing.sm),
              ...filtered
                  .where((memory) => memory.isPinned)
                  .map((memory) => _MemoryBrainCard(memory: memory)),
              const SizedBox(height: AppSpacing.lg),
              const SectionTitle(title: 'Most Important'),
              const SizedBox(height: AppSpacing.sm),
              ...filtered
                  .take(5)
                  .map((memory) => _MemoryBrainCard(memory: memory)),
              const SizedBox(height: AppSpacing.lg),
              const SectionTitle(title: 'Memory Timeline'),
              const SizedBox(height: AppSpacing.sm),
              timelineAsync.maybeWhen(
                data: (timeline) => _TimelineView(timeline: timeline),
                orElse: () => const SizedBox.shrink(),
              ),
              if (filtered.isEmpty)
                const SizedBox(
                  height: 260,
                  child: AppEmptyState(
                    title: "Let's create your first memory.",
                    message:
                        'Tell MAXie things like your birthday, goals, projects, favorites, or dream company.',
                    icon: Icons.psychology_rounded,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<MemoryModel> _filter(List<MemoryModel> memories) {
    final query = _query.trim().toLowerCase();
    return memories.where((memory) {
      final categoryMatches = _category == null || memory.category == _category;
      final queryMatches =
          query.isEmpty ||
          memory.title.toLowerCase().contains(query) ||
          memory.value.toLowerCase().contains(query) ||
          memory.tags.any((tag) => tag.toLowerCase().contains(query));
      return categoryMatches && queryMatches && !memory.isArchived;
    }).toList();
  }
}

class _RelationshipPanel extends StatelessWidget {
  const _RelationshipPanel({required this.stats});

  final RelationshipStats stats;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      glowColor: AppColors.seed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Relationship Engine',
            subtitle: 'Trust, friendship, and history foundation.',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MiniStat(
                label: 'Friendship',
                value: 'Lv ${stats.friendshipLevel}',
              ),
              _MiniStat(label: 'Trust', value: '${stats.trustLevel}%'),
              _MiniStat(label: 'Days', value: '${stats.daysTogether}'),
              _MiniStat(label: 'Messages', value: '${stats.messagesExchanged}'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final milestone in stats.milestones)
                Chip(
                  avatar: const Icon(Icons.emoji_events_rounded, size: 16),
                  label: Text(milestone),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 240.ms).slideY(begin: 0.06, end: 0);
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final MemorySummary summary;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.1,
      children: [
        _MiniStat(label: 'Memories', value: '${summary.totalMemories}'),
        _MiniStat(label: 'Pinned', value: '${summary.pinnedMemories}'),
        _MiniStat(label: 'Level', value: '${summary.relationshipLevel}'),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final MemoryCategory? selected;
  final ValueChanged<MemoryCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final categories = [
      null,
      MemoryCategory.projects,
      MemoryCategory.goals,
      MemoryCategory.skills,
      MemoryCategory.interests,
      MemoryCategory.birthdays,
      MemoryCategory.dreamCompanies,
      MemoryCategory.preferences,
    ];
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final category in categories)
          FilterChip(
            selected: selected == category,
            label: Text(category == null ? 'All' : _label(category)),
            onSelected: (_) => onSelected(category),
          ),
      ],
    );
  }

  String _label(MemoryCategory category) {
    return category.name
        .replaceAllMapped(RegExp('[A-Z]'), (match) => ' ${match.group(0)}')
        .trim();
  }
}

class _MemoryBrainCard extends ConsumerWidget {
  const _MemoryBrainCard({required this.memory});

  final MemoryModel memory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: PremiumCard(
        glowColor: memory.isPinned ? AppColors.warmCoral : AppColors.calmTeal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon(memory.category), color: AppColors.calmTeal),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    memory.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Chip(label: Text(memory.priority.name)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(memory.value),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                Chip(label: Text(memory.category.name)),
                Chip(label: Text('${(memory.confidence * 100).round()}%')),
                if (memory.isPinned) const Chip(label: Text('Pinned')),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _show(
                    context,
                    'Tap delete and save a corrected memory from chat.',
                  ),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () =>
                      _show(context, 'Memory is stored locally for this demo.'),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('Export'),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () async {
                    await ref
                        .read(memoryBrainServiceProvider)
                        .deleteMemory(memory.id);
                    ref.invalidate(memoryBrainListProvider);
                    ref.invalidate(memoryBrainSummaryProvider);
                    ref.invalidate(memoryBrainTimelineProvider);
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(MemoryCategory category) {
    return switch (category) {
      MemoryCategory.birthdays => Icons.cake_rounded,
      MemoryCategory.dreamCompanies => Icons.apartment_rounded,
      MemoryCategory.projects => Icons.rocket_launch_rounded,
      MemoryCategory.skills => Icons.code_rounded,
      MemoryCategory.goals => Icons.flag_rounded,
      _ => Icons.psychology_rounded,
    };
  }

  void _show(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TimelineView extends StatelessWidget {
  const _TimelineView({required this.timeline});

  final MemoryTimeline timeline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in timeline.groups)
          if (group.memories.isNotEmpty) ...[
            Text(
              group.label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final memory in group.memories.take(4))
              _TimelineItem(memory: memory),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.memory});

  final MemoryModel memory;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 10, color: AppColors.calmTeal),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text('${memory.title}: ${memory.value}'),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
