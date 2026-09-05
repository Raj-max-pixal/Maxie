import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  final List<Map<String, dynamic>> _goals = [
    {'title': 'Learn something new', 'done': false, 'icon': Icons.school},
    {'title': 'Exercise daily', 'done': true, 'icon': Icons.fitness_center},
    {'title': 'Read 30 minutes', 'done': false, 'icon': Icons.menu_book},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Goals'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Today\'s Goals', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${_goals.where((g) => g['done'] == true).length}/${_goals.length} completed',
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                ..._goals.map((goal) => CheckboxListTile(
                      value: goal['done'],
                      onChanged: (v) => setState(() => goal['done'] = v),
                      title: Text(goal['title'] as String),
                      secondary: Icon(goal['icon'] as IconData, color: theme.colorScheme.primary),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}