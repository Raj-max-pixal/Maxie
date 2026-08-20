import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/memory/application/memory_providers.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_categories.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_tags.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
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

class _MemoryScreenState extends ConsumerState<MemoryScreen> {
  String _searchQuery = '';
  String _timelineFilter = 'All Time';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoryManagerProvider);

    return PremiumScaffold(
      title: 'Memory Brain',
      child: state.isLoading && state.memories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(memoryManagerProvider.notifier).load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                children: [
                  if (state.pendingSuggestion != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _MemorySuggestionBanner(
                        suggestion: state.pendingSuggestion!,
                        onSave: () async {
                          await ref.read(memoryManagerProvider.notifier).acceptSuggestion();
                          _showMessage(context, 'I\'ll remember that.', emotion: 'happy');
                        },
                        onEdit: () => _editSuggestion(context, state.pendingSuggestion!),
                        onIgnore: () {
                          ref.read(memoryManagerProvider.notifier).ignoreSuggestion();
                          _showMessage(context, 'Ignored memory suggestion.');
                        },
                      ),
                    ),

                  const SectionTitle(title: 'Dashboard', subtitle: 'A snapshot of everything MAXie knows.'),
                  const SizedBox(height: AppSpacing.sm),
                  _MemoryDashboard(
                    summary: state.summary,
                    memories: state.memories,
                    relationship: state.relationship,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  const SectionTitle(title: 'Relationship Insights', subtitle: 'How you and MAXie are growing together.'),
                  const SizedBox(height: AppSpacing.sm),
                  _RelationshipInsights(relationship: state.relationship),
                  const SizedBox(height: AppSpacing.lg),

                  const SectionTitle(title: 'Memory Insights', subtitle: 'What MAXie has noticed about you.'),
                  const SizedBox(height: AppSpacing.sm),
                  _MemoryInsights(memories: state.memories),
                  const SizedBox(height: AppSpacing.lg),

                  const SectionTitle(title: 'Search & Timeline', subtitle: 'Find specific memories.'),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search memories by keyword, category, or tag...',
                      prefixIcon: Icon(Icons.search_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All Time', 'Today', 'Yesterday', 'Last Week', 'Last Month'].map((filter) {
                        final isSelected = _timelineFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _timelineFilter = filter;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _buildTimeline(state.memories),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeline(List<MemoryRecord> memories) {
    var filtered = memories.where((m) => m.searchableText.contains(_searchQuery.toLowerCase())).toList();
    
    final now = DateTime.now();
    if (_timelineFilter == 'Today') {
      filtered = filtered.where((m) => now.difference(m.createdAt).inDays == 0 && now.day == m.createdAt.day).toList();
    } else if (_timelineFilter == 'Yesterday') {
      filtered = filtered.where((m) => now.difference(m.createdAt).inDays == 1 || (now.difference(m.createdAt).inDays == 0 && now.day != m.createdAt.day)).toList();
    } else if (_timelineFilter == 'Last Week') {
      filtered = filtered.where((m) => now.difference(m.createdAt).inDays <= 7).toList();
    } else if (_timelineFilter == 'Last Month') {
      filtered = filtered.where((m) => now.difference(m.createdAt).inDays <= 30).toList();
    }

    if (filtered.isEmpty) {
      return const _EmptySection(text: 'No memories found for the current filter.');
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filtered.map((memory) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _MemoryCard(
            memory: memory,
            onPin: () async {
              await ref.read(memoryManagerProvider.notifier).pinMemory(memory.id, pinned: !memory.isPinned);
            },
            onEdit: () => _editMemory(context, memory),
            onDelete: () async {
              await ref.read(memoryManagerProvider.notifier).deleteMemory(memory.id);
              if (context.mounted) _showMessage(context, 'I\'ll forget it.');
            },
          ),
        );
      }).toList(),
    );
  }

  Future<void> _editSuggestion(BuildContext context, MemorySuggestion suggestion) async {
    final titleController = TextEditingController(text: suggestion.memory.title);
    final valueController = TextEditingController(text: suggestion.memory.value);

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
                  title: titleController.text.trim().isEmpty ? suggestion.memory.title : titleController.text.trim(),
                  value: valueController.text.trim().isEmpty ? suggestion.memory.value : valueController.text.trim(),
                  updatedAt: DateTime.now(),
                );
                await ref.read(memoryManagerProvider.notifier).saveMemory(updated);
                if (!context.mounted || !dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                ref.read(memoryManagerProvider.notifier).ignoreSuggestion();
                _showMessage(context, 'Got it! Updated.', emotion: 'happy');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editMemory(BuildContext context, MemoryRecord memory) async {
    final titleController = TextEditingController(text: memory.title);
    final valueController = TextEditingController(text: memory.value);

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
                final updated = memory.copyWith(
                  title: titleController.text.trim().isEmpty ? memory.title : titleController.text.trim(),
                  value: valueController.text.trim().isEmpty ? memory.value : valueController.text.trim(),
                  updatedAt: DateTime.now(),
                );
                await ref.read(memoryManagerProvider.notifier).saveMemory(updated);
                if (!context.mounted || !dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _showMessage(context, 'Got it! Updated.', emotion: 'happy');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(BuildContext context, String message, {String emotion = 'idle'}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(
          children: [
            MaxieCompanionView(size: 24, state: emotion == 'happy' ? CompanionPresence.happy : CompanionPresence.idle),
            const SizedBox(width: AppSpacing.sm),
            Text(message),
          ],
        ),
      ));
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
  final VoidCallback onSave;
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
                      '?? New Memory Detected',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ).animate().shimmer(duration: 1200.ms, delay: 400.ms),
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
          _MemoryMetaGrid(memory: suggestion.memory, confidence: suggestion.confidence),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              FilledButton.icon(
                onPressed: onSave,
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
    final goals = memories.where((memory) => memory.category == MemoryCategory.goals).length;
    final favorites = memories.where((memory) => memory.isFavorite).length;
    final projects = memories.where((memory) => memory.category == MemoryCategory.projects).length;
    final skills = memories.where((memory) => memory.category == MemoryCategory.skills).length;
    final achievements = memories.where((memory) => memory.category == MemoryCategory.achievements).length;
    final friends = memories.where((memory) => memory.category == MemoryCategory.friends).length;
    final dates = memories.where((memory) => memory.category == MemoryCategory.importantDates || memory.category == MemoryCategory.birthdays).length;
    final important = memories.where((memory) => memory.priority.weight >= 3 || memory.importance.weight >= 3).length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.55,
      children: [
        _DashboardTile(icon: Icons.psychology_rounded, label: 'Memories', value: '${summary.totalMemories}'),
        _DashboardTile(icon: Icons.flag_rounded, label: 'Goals', value: '$goals', color: AppColors.calmTeal),
        _DashboardTile(icon: Icons.favorite_rounded, label: 'Favorites', value: '$favorites', color: AppColors.warmCoral),
        _DashboardTile(icon: Icons.workspaces_rounded, label: 'Projects', value: '$projects', color: AppColors.warning),
        _DashboardTile(icon: Icons.code_rounded, label: 'Skills', value: '$skills', color: AppColors.calmTeal),
        _DashboardTile(icon: Icons.emoji_events_rounded, label: 'Achievements', value: '$achievements', color: AppColors.warning),
        _DashboardTile(icon: Icons.group_rounded, label: 'Friends', value: '$friends', color: AppColors.seed),
        _DashboardTile(icon: Icons.calendar_month_rounded, label: 'Key Dates', value: '$dates', color: AppColors.warmCoral),
        _DashboardTile(icon: Icons.favorite_border_rounded, label: 'Relationship', value: 'Lv ${relationship.friendshipLevel}', color: AppColors.warmCoral),
        _DashboardTile(icon: Icons.star_rounded, label: 'Important', value: '$important', color: AppColors.warning),
      ],
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.05, end: 0);
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.seed,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
          ).animate().slideX(duration: 400.ms, begin: -0.2, end: 0).fadeIn(),
        ],
      ),
    );
  }
}

class _MemoryInsights extends StatelessWidget {
  const _MemoryInsights({required this.memories});
  final List<MemoryRecord> memories;

  @override
  Widget build(BuildContext context) {
    final insights = <String>[];
    
    final projects = memories.where((m) => m.category == MemoryCategory.projects).toList();
    if (projects.isNotEmpty) {
      insights.add("You've shared  project with me.");
    }
    
    final interests = memories.where((m) => m.category == MemoryCategory.interests).toList();
    if (interests.isNotEmpty) {
      insights.add("You seem most interested in .");
    }

    if (insights.isEmpty) {
      insights.add("I'm still learning about you. Keep chatting to generate insights!");
    }

    return Column(
      children: insights.map((insight) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: PremiumCard(
          glowColor: AppColors.calmTeal,
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(insight, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      )).toList(),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _RelationshipInsights extends StatelessWidget {
  const _RelationshipInsights({required this.relationship});
  final MemoryRelationshipState relationship;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatPill(label: 'Days Together', value: '${relationship.daysTogether}')),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatPill(label: 'Friendship XP', value: '${relationship.xpEarnedTogether}')),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: _StatPill(label: 'Conversations', value: '${relationship.conversationCount}')),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatPill(label: 'Messages', value: '${relationship.messagesExchanged}')),
          ],
        ),
        if (relationship.milestones.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          PremiumCard(
            glowColor: AppColors.warmCoral,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: AppColors.warmCoral),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Milestones', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...relationship.milestones.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(m, style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2540),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white54, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
        ],
      ),
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
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
                    Chip(label: Text(info.label, style: const TextStyle(fontSize: 10)), padding: EdgeInsets.zero),
                    Chip(label: Text(memory.priority.label, style: const TextStyle(fontSize: 10)), padding: EdgeInsets.zero),
                    if (memory.isPinned) const Chip(label: Text('Pinned', style: TextStyle(fontSize: 10)), padding: EdgeInsets.zero),
                    if (memory.isFavorite) const Chip(label: Text('Favorite', style: TextStyle(fontSize: 10)), padding: EdgeInsets.zero),
                  ],
                ),
                const SizedBox(height: 2),
                _MemoryMetaGrid(memory: memory, confidence: memory.confidence),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'pin': onPin(); break;
                case 'edit': onEdit(); break;
                case 'delete': onDelete(); break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'pin', child: Text(memory.isPinned ? 'Unpin' : 'Pin')),
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
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
    final used = memory.lastUsedAt == null ? 'Never' : _formatRelativeDate(memory.lastUsedAt!);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _MemoryMetaPill(label: 'Confidence', value: '%', color: AppColors.success),
        _MemoryMetaPill(label: 'Importance', value: _stars(memory.importance.weight), color: AppColors.warning),
        _MemoryMetaPill(label: 'Source', value: memory.source.name.toUpperCase()),
        _MemoryMetaPill(label: 'Created', value: created),
        _MemoryMetaPill(label: 'Used', value: ' (x)'),
      ],
    );
  }

  String _stars(int weight) => List.filled(weight.clamp(1, 5), '?').join();
}

class _MemoryMetaPill extends StatelessWidget {
  const _MemoryMetaPill({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1624),
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final deltaDays = DateTime(now.year, now.month, now.day).difference(DateTime(date.year, date.month, date.day)).inDays;
  if (deltaDays <= 0) return 'Today';
  if (deltaDays == 1) return 'Yesterday';
  return '//';
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
      ),
    );
  }
}
