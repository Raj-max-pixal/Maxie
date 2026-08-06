import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/memory/application/memory_providers.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_categories.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_tags.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/maxie_companion_view.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key});

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

                await ref
                    .read(memoryManagerProvider.notifier)
                    .saveMemory(updated);
                if (!context.mounted || !dialogContext.mounted) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                _showMessage(context, 'Memory updated.');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editSuggestion(
    BuildContext context,
    MemorySuggestion suggestion,
  ) async {
    final titleController = TextEditingController(
      text: suggestion.memory.title,
    );
    final valueController = TextEditingController(
      text: suggestion.memory.value,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Memory'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: valueController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Value'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final updated = suggestion.memory.copyWith(
                  title: titleController.text.trim().isEmpty
                      ? suggestion.memory.title
                      : titleController.text.trim(),
                  value: valueController.text.trim().isEmpty
                      ? suggestion.memory.value
                      : valueController.text.trim(),
                  updatedAt: DateTime.now(),
                );
                await ref
                    .read(memoryManagerProvider.notifier)
                    .saveMemory(updated);
                if (!context.mounted || !dialogContext.mounted) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                _showMessage(context, 'Memory saved.');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportMemories(
    BuildContext context,
    List<MemoryRecord> memories,
  ) async {
    final payload = const JsonEncoder.withIndent(
      '  ',
    ).convert(memories.map((memory) => memory.toJson()).toList());
    await Clipboard.setData(ClipboardData(text: payload));
    if (!context.mounted) {
      return;
    }
    _showMessage(context, 'Memory export copied to clipboard.');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MemorySuggestionBanner extends StatelessWidget {
  const _MemorySuggestionBanner({
    required this.suggestion,
    required this.onSave,
    required this.onEdit,
    required this.onIgnore,
  });

  final MemorySuggestion suggestion;
  final Future<void> Function() onSave;
  final VoidCallback onEdit;
  final VoidCallback onIgnore;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      glowColor: AppColors.calmTeal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MaxieCompanionView(size: 68),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🧠 New Memory Detected',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.memory.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      suggestion.memory.value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _MemoryMetaGrid(
            memory: suggestion.memory,
            confidence: suggestion.confidence,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              FilledButton.icon(
                onPressed: () {
                  onSave();
                },
                icon: const Icon(Icons.bookmark_add_rounded),
                label: const Text('Save'),
              ),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: onIgnore,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Ignore'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            suggestion.reason,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 240.ms).slideY(begin: 0.04, end: 0);
  }
}

class _MemoryDashboard extends StatelessWidget {
  const _MemoryDashboard({
    required this.summary,
    required this.memories,
    required this.relationship,
  });

  final MemorySummary summary;
  final List<MemoryRecord> memories;
  final MemoryRelationshipState relationship;

  @override
  Widget build(BuildContext context) {
    final goals = memories
        .where((memory) => memory.category == MemoryCategory.goals)
        .length;
    final favorites = memories.where((memory) => memory.isFavorite).length;
    final projects = memories
        .where((memory) => memory.category == MemoryCategory.projects)
        .length;
    final important = memories
        .where(
          (memory) =>
              memory.priority == MemoryPriority.high ||
              memory.priority == MemoryPriority.critical ||
              memory.importance == MemoryImportance.high ||
              memory.importance == MemoryImportance.vital,
        )
        .length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.55,
      children: [
        _DashboardTile(
          icon: Icons.psychology_rounded,
          label: 'Memories',
          value: '${summary.totalMemories}',
        ),
        _DashboardTile(
          icon: Icons.flag_rounded,
          label: 'Goals',
          value: '$goals',
        ),
        _DashboardTile(
          icon: Icons.favorite_rounded,
          label: 'Favorites',
          value: '$favorites',
        ),
        _DashboardTile(
          icon: Icons.workspaces_rounded,
          label: 'Projects',
          value: '$projects',
        ),
        _DashboardTile(
          icon: Icons.favorite_border_rounded,
          label: 'Relationship',
          value: 'Level ${relationship.friendshipLevel}',
        ),
        _DashboardTile(
          icon: Icons.star_rounded,
          label: 'Important',
          value: '$important',
        ),
      ],
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.05, end: 0);
  }
}

class _MemorySection extends StatelessWidget {
  const _MemorySection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title, subtitle: subtitle),
        const SizedBox(height: AppSpacing.sm),
        ...children.map(
          (child) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.memory,
    required this.onPin,
    required this.onEdit,
    required this.onDelete,
  });

  final MemoryRecord memory;
  final VoidCallback onPin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final info = MemoryCategories.info(memory.category);
    return PremiumCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.calmTeal.withValues(alpha: 0.15),
            child: Icon(info.icon, color: AppColors.calmTeal),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  memory.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Chip(label: Text(info.label)),
                    Chip(label: Text(memory.priority.label)),
                    if (memory.isPinned) const Chip(label: Text('Pinned')),
                    if (memory.isFavorite) const Chip(label: Text('Favorite')),
                  ],
                ),
                const SizedBox(height: 2),
                _MemoryMetaGrid(memory: memory, confidence: memory.confidence),
                const SizedBox(height: 6),
                Text(
                  'Saved ${_formatDate(memory.createdAt)} · Confidence ${(memory.confidence * 100).round()}%',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'pin':
                  onPin();
                  break;
                case 'edit':
                  onEdit();
                  break;
                case 'delete':
                  onDelete();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pin',
                child: Text(memory.isPinned ? 'Unpin' : 'Pin'),
              ),
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.info,
    required this.selected,
    required this.onTap,
  });

  final MemoryCategoryInfo info;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      glowColor: selected ? AppColors.warmCoral : AppColors.calmTeal,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            info.icon,
            color: selected ? AppColors.warmCoral : AppColors.calmTeal,
          ),
          const SizedBox(height: 6),
          Text(
            info.label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _TimelineGroup extends StatelessWidget {
  const _TimelineGroup({
    required this.label,
    required this.entries,
    required this.onPin,
    required this.onEdit,
    required this.onDelete,
  });

  final String label;
  final List<MemoryRecord> entries;
  final ValueChanged<MemoryRecord> onPin;
  final ValueChanged<MemoryRecord> onEdit;
  final ValueChanged<MemoryRecord> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.sm,
            top: AppSpacing.xs,
          ),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        for (final memory in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _MemoryCard(
              memory: memory,
              onPin: () => onPin(memory),
              onEdit: () => onEdit(memory),
              onDelete: () => onDelete(memory),
            ),
          ),
      ],
    );
  }
}

class _TimelineEntryGroup {
  const _TimelineEntryGroup(this.label, this.items);

  final String label;
  final List<MemoryRecord> items;
}

class _MemoryDashboard extends StatelessWidget {
  const _MemoryDashboard({
    required this.summary,
    required this.memories,
    required this.relationship,
  });

  final MemorySummary summary;
  final List<MemoryRecord> memories;
  final MemoryRelationshipState relationship;

  @override
  Widget build(BuildContext context) {
    final goals = memories
        .where((memory) => memory.category == MemoryCategory.goals)
        .length;
    final favorites = memories.where((memory) => memory.isFavorite).length;
    final projects = memories
        .where((memory) => memory.category == MemoryCategory.projects)
        .length;
    final important = memories
        .where(
          (memory) =>
              memory.priority == MemoryPriority.high ||
              memory.priority == MemoryPriority.critical ||
              memory.importance == MemoryImportance.high ||
              memory.importance == MemoryImportance.vital,
        )
        .length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.55,
      children: [
        _DashboardTile(
          icon: Icons.psychology_rounded,
          label: 'Memories',
          value: '${summary.totalMemories}',
        ),
        _DashboardTile(
          icon: Icons.flag_rounded,
          label: 'Goals',
          value: '$goals',
        ),
        _DashboardTile(
          icon: Icons.favorite_rounded,
          label: 'Favorites',
          value: '$favorites',
        ),
        _DashboardTile(
          icon: Icons.workspaces_rounded,
          label: 'Projects',
          value: '$projects',
        ),
        _DashboardTile(
          icon: Icons.favorite_border_rounded,
          label: 'Relationship',
          value: 'Level ${relationship.friendshipLevel}',
        ),
        _DashboardTile(
          icon: Icons.star_rounded,
          label: 'Important',
          value: '$important',
        ),
      ],
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.05, end: 0);
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      glowColor: AppColors.seed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.calmTeal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _MemoryMetaGrid extends StatelessWidget {
  const _MemoryMetaGrid({required this.memory, required this.confidence});

  final MemoryRecord memory;
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final created = _formatRelativeDate(memory.createdAt);
    final used = memory.lastUsedAt == null
        ? 'Never'
        : _formatRelativeDate(memory.lastUsedAt!);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _MemoryMetaPill(
          label: 'Category',
          value: _categoryLabel(memory.category),
        ),
        _MemoryMetaPill(
          label: 'Importance',
          value: _stars(memory.importance.weight),
        ),
        _MemoryMetaPill(
          label: 'Confidence',
          value: '${(confidence * 100).round()}%',
        ),
        _MemoryMetaPill(
          label: 'Source',
          value: memory.source.name.toUpperCase(),
        ),
        _MemoryMetaPill(label: 'Created', value: created),
        _MemoryMetaPill(label: 'Used', value: used),
      ],
    );
  }

  String _categoryLabel(MemoryCategory category) {
    return switch (category) {
      MemoryCategory.userProfile => 'User Profile',
      MemoryCategory.goals => 'Goals',
      MemoryCategory.dreamCompanies => 'Dream Companies',
      MemoryCategory.projects => 'Projects',
      MemoryCategory.skills => 'Skills',
      MemoryCategory.interests => 'Interests',
      MemoryCategory.favoriteApps => 'Favorite Apps',
      MemoryCategory.favoriteSongs => 'Favorite Songs',
      MemoryCategory.favoriteMovies => 'Favorite Movies',
      MemoryCategory.favoriteGames => 'Favorite Games',
      MemoryCategory.college => 'College',
      MemoryCategory.friends => 'Friends',
      MemoryCategory.family => 'Family',
      MemoryCategory.birthdays => 'Birthday',
      MemoryCategory.importantDates => 'Important Dates',
      MemoryCategory.achievements => 'Achievements',
      MemoryCategory.habits => 'Habits',
      MemoryCategory.dailyRoutine => 'Daily Routine',
      MemoryCategory.preferences => 'Preferences',
      MemoryCategory.pinned => 'Pinned',
      MemoryCategory.conversation => 'Conversation',
    };
  }

  String _stars(int weight) => List.filled(weight.clamp(1, 5), '★').join();
}

class _MemoryMetaPill extends StatelessWidget {
  const _MemoryMetaPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1624),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

String _formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final deltaDays = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(date.year, date.month, date.day)).inDays;
  if (deltaDays <= 0) {
    return 'Today';
  }
  if (deltaDays == 1) {
    return 'Yesterday';
  }
  return '${date.month}/${date.day}/${date.year}';
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
      ),
    );
  }
}
