import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/glass_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final achievements = [
      {'name': 'First Chat', 'desc': 'Send your first message', 'icon': Icons.chat, 'unlocked': true},
      {'name': 'Pet Lover', 'desc': 'Adopt 3 pets', 'icon': Icons.pets, 'unlocked': true},
      {'name': 'Productive', 'desc': 'Complete 10 tasks', 'icon': Icons.check_circle, 'unlocked': false},
      {'name': 'Streak Master', 'desc': '7 day streak', 'icon': Icons.local_fire_department, 'unlocked': false},
      {'name': 'Friend', 'desc': 'Reach friendship level 5', 'icon': Icons.favorite, 'unlocked': false},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: theme.colorScheme.primary, size: 32),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${achievements.where((a) => a['unlocked'] == true).length}/${achievements.length}',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        Text('Achievements Unlocked', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: achievements.where((a) => a['unlocked'] == true).length / achievements.length,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...achievements.map((a) => GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (a['unlocked'] as bool)
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        a['icon'] as IconData,
                        color: (a['unlocked'] as bool) ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a['name'] as String,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          Text(a['desc'] as String, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Icon(
                      (a['unlocked'] as bool) ? Icons.check_circle : Icons.lock_outline,
                      color: (a['unlocked'] as bool) ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}