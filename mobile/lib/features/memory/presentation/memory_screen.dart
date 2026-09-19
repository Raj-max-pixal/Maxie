import 'package:flutter/material.dart';
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
                  onPressed: () => _edit(context, ref),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await ref
                        .read(memoryBrainServiceProvider)
                        .pinMemory(memory.id, pinned: !memory.isPinned);
                    _refresh(ref);
                  },
                  icon: Icon(
                    memory.isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                  ),
                  label: Text(memory.isPinned ? 'Unpin' : 'Pin'),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Forget memory',
                  onPressed: () => _forget(context, ref),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: memory.value);
    final updated = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit memory'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (updated == null || updated.trim().isEmpty) return;
    await ref
        .read(memoryBrainServiceProvider)
        .updateMemory(memory.copyWith(value: updated.trim()));
    _refresh(ref);
  }

  Future<void> _forget(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forget this memory?'),
        content: const Text('MAXie will stop using this memory.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Forget'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(memoryBrainServiceProvider).forgetMemory(memory.id);
    _refresh(ref);
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(memoryBrainListProvider);
    ref.invalidate(memoryBrainSummaryProvider);
    ref.invalidate(memoryBrainTimelineProvider);
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
