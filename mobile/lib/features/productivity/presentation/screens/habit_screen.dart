import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class Habit {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final Color color;
  final List<DateTime> completedDates;
  final DateTime createdAt;
  final int targetDays;
  final String? reminderTime;

  const Habit({
    required this.id,
    required this.name,
    this.description,
    this.icon = '⭐',
    this.color = Colors.purple,
    this.completedDates = const [],
    required this.createdAt,
    this.targetDays = 21,
    this.reminderTime,
  });

  int get streak {
    if (completedDates.isEmpty) return 0;
    final sorted = List<DateTime>.from(completedDates)..sort((a, b) => b.compareTo(a));
    int count = 0;
    final today = DateTime.now();
    var checkDate = today;

    for (final date in sorted) {
      if (date.year == checkDate.year && date.month == checkDate.month && date.day == checkDate.day) {
        count++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(checkDate)) {
        break;
      }
    }
    return count;
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    return completedDates.any((d) =>
      d.year == today.year && d.month == today.month && d.day == today.day);
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    Color? color,
    List<DateTime>? completedDates,
    DateTime? createdAt,
    int? targetDays,
    String? reminderTime,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
      targetDays: targetDays ?? this.targetDays,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

class HabitNotifier extends StateNotifier<List<Habit>> {
  HabitNotifier() : super(_defaultHabits);

  static final List<Habit> _defaultHabits = [
    Habit(id: '1', name: 'Drink Water', icon: '💧', color: Colors.blue, createdAt: DateTime.now().subtract(const Duration(days: 5))),
    Habit(id: '2', name: 'Read Daily', icon: '📚', color: Colors.orange, createdAt: DateTime.now().subtract(const Duration(days: 3))),
    Habit(id: '3', name: 'Exercise', icon: '🏃', color: Colors.green, createdAt: DateTime.now().subtract(const Duration(days: 2))),
    Habit(id: '4', name: 'Meditate', icon: '🧘', color: Colors.purple, createdAt: DateTime.now().subtract(const Duration(days: 1))),
  ];

  void addHabit(Habit habit) {
    state = [...state, habit];
  }

  void toggleHabit(String id) {
    state = state.map((habit) {
      if (habit.id == id) {
        final today = DateTime.now();
        final isCompleted = habit.isCompletedToday();
        final updatedDates = isCompleted
            ? habit.completedDates.where((d) =>
                !(d.year == today.year && d.month == today.month && d.day == today.day)).toList()
            : [...habit.completedDates, today];
        return habit.copyWith(completedDates: updatedDates);
      }
      return habit;
    }).toList();
  }

  void deleteHabit(String id) {
    state = state.where((h) => h.id != id).toList();
  }

  int get totalCompletionsToday {
    final today = DateTime.now();
    return state.where((h) => h.isCompletedToday()).length;
  }

  int get currentStreak {
    if (state.isEmpty) return 0;
    return state.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  return HabitNotifier();
});

class HabitScreen extends ConsumerStatefulWidget {
  const HabitScreen({super.key});

  @override
  ConsumerState<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends ConsumerState<HabitScreen> {
  void _showAddHabitDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedIcon = '⭐';
    Color selectedColor = Colors.purple;
    int targetDays = 21;

    final icons = ['⭐', '💪', '📚', '🧘', '🏃', '💧', '🥗', '🎯', '✍️', '🎨', '🧠', '🌱'];
    final colors = [Colors.purple, Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.teal, Colors.pink, Colors.indigo];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Habit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Habit name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Icon', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: icons.map((icon) => ChoiceChip(
                    label: Text(icon, style: const TextStyle(fontSize: 20)),
                    selected: selectedIcon == icon,
                    onSelected: (_) => setDialogState(() => selectedIcon = icon),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                Text('Color', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: colors.map((color) => GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selectedColor == color
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                Text('Target: $targetDays days', style: Theme.of(context).textTheme.labelMedium),
                Slider(
                  value: targetDays.toDouble(),
                  min: 7,
                  max: 100,
                  divisions: 93,
                  label: '$targetDays days',
                  onChanged: (v) => setDialogState(() => targetDays = v.round()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(habitProvider.notifier).addHabit(Habit(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    description: descController.text.isNotEmpty ? descController.text : null,
                    icon: selectedIcon,
                    color: selectedColor,
                    createdAt: DateTime.now(),
                    targetDays: targetDays,
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Create Habit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habits = ref.watch(habitProvider);
    final notifier = ref.read(habitProvider.notifier);
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1)).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, size: 16, color: Colors.orange.shade400),
                const SizedBox(width: 4),
                Text('${notifier.currentStreak}', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Weekly progress chart
          GlassCard(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This Week', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: habits.length.toDouble().clamp(1, double.infinity),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                return Text(days[value.toInt() % 7], style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (i) {
                          final date = today.subtract(Duration(days: 6 - i));
                          final count = habits.where((h) =>
                            h.completedDates.any((d) =>
                              d.year == date.year && d.month == date.month && d.day == date.day)
                          ).length;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: count.toDouble(),
                                color: theme.colorScheme.primary,
                                width: 12,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Habits list
          Expanded(
            child: habits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 80, color: theme.colorScheme.primary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('No habits yet', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Create your first habit!', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      final progress = habit.streak / habit.targetDays;
                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => ref.read(habitProvider.notifier).toggleHabit(habit.id),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: habit.color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(habit.icon, style: const TextStyle(fontSize: 24)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(habit.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: progress.clamp(0.0, 1.0),
                                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                        color: habit.color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${habit.streak}/${habit.targetDays} days',
                                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () => ref.read(habitProvider.notifier).toggleHabit(habit.id),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: habit.isCompletedToday()
                                          ? habit.color
                                          : theme.colorScheme.surfaceContainerHighest,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      habit.isCompletedToday() ? Icons.check : Icons.add,
                                      size: 18,
                                      color: habit.isCompletedToday() ? Colors.white : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}