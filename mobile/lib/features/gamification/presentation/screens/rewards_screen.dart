import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rewards = [
      {'name': 'Daily Login', 'coins': 50, 'claimed': false, 'icon': Icons.login},
      {'name': 'Chat Streak', 'coins': 100, 'claimed': false, 'icon': Icons.chat_bubble},
      {'name': 'Task Master', 'coins': 200, 'claimed': true, 'icon': Icons.task_alt},
      {'name': 'Pet Collector', 'coins': 150, 'claimed': false, 'icon': Icons.pets},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.monetization_on, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Coins', style: theme.textTheme.bodySmall),
                    Text('1,250', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Daily Rewards', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...rewards.map((r) => GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (r['claimed'] as bool)
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(r['icon'] as IconData,
                        color: (r['claimed'] as bool) ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                  ),
                  title: Text(r['name'] as String),
                  subtitle: Text('+${r['coins']} coins', style: TextStyle(color: Colors.amber.shade700)),
                  trailing: (r['claimed'] as bool)
                      ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                      : ElevatedButton(
                          onPressed: () {},
                          child: const Text('Claim'),
                        ),
                ),
              )),
        ],
      ),
    );
  }
}