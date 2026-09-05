import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';

class TodoItem {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? category;
  final int priority;

  const TodoItem({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.category,
    this.priority = 0,
  });

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    String? category,
    int? priority,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }
}

class TodoNotifier extends StateNotifier<List<TodoItem>> {
  TodoNotifier() : super([]);

  void addTodo(TodoItem item) {
    state = [...state, item];
  }

  void toggleTodo(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo;
    }).toList();
  }

  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  void updateTodo(TodoItem updated) {
    state = state.map((todo) => todo.id == updated.id ? updated : todo).toList();
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, List<TodoItem>>((ref) {
  return TodoNotifier();
});

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDueDate;
  String? _selectedCategory;
  int _selectedPriority = 0;

  final List<String> _categories = ['Work', 'Personal', 'Study', 'Health', 'Shopping', 'Other'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showAddTodoDialog() {
    _titleController.clear();
    _descController.clear();
    _selectedDueDate = null;
    _selectedCategory = null;
    _selectedPriority = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setDialogState(() => _selectedCategory = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setDialogState(() => _selectedDueDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Due date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _selectedDueDate != null
                                ? DateFormat('MMM d').format(_selectedDueDate!)
                                : 'Pick date',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Priority: ', style: Theme.of(context).textTheme.bodyMedium),
                    for (int i = 1; i <= 3; i++)
                      ChoiceChip(
                        label: Text('$i'),
                        selected: _selectedPriority == i,
                        onSelected: (_) => setDialogState(() => _selectedPriority = i),
                      ),
                  ],
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
                if (_titleController.text.isNotEmpty) {
                  ref.read(todoProvider.notifier).addTodo(TodoItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text,
                    description: _descController.text.isNotEmpty ? _descController.text : null,
                    createdAt: DateTime.now(),
                    dueDate: _selectedDueDate,
                    category: _selectedCategory,
                    priority: _selectedPriority,
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todos = ref.watch(todoProvider);
    final completedCount = todos.where((t) => t.isCompleted).length;
    final pendingCount = todos.length - completedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green.shade400),
                const SizedBox(width: 4),
                Text('$completedCount/$pendingCount', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
      body: todos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 80, color: theme.colorScheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No tasks yet', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Add your first task!', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return Dismissible(
                  key: Key(todo.id),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      todo.isCompleted ? Icons.undo : Icons.check,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      ref.read(todoProvider.notifier).removeTodo(todo.id);
                    } else {
                      ref.read(todoProvider.notifier).toggleTodo(todo.id);
                    }
                  },
                  child: GlassCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Checkbox(
                        value: todo.isCompleted,
                        onChanged: (_) => ref.read(todoProvider.notifier).toggleTodo(todo.id),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                          color: todo.isCompleted ? theme.colorScheme.onSurfaceVariant : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (todo.description != null) Text(todo.description!, maxLines: 1),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (todo.category != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(todo.category!, style: const TextStyle(fontSize: 11)),
                                ),
                              if (todo.dueDate != null) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.schedule, size: 14, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM d').format(todo.dueDate!),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                              if (todo.priority > 0) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.flag, size: 14, color: todo.priority == 3 ? Colors.red : todo.priority == 2 ? Colors.orange : Colors.yellow.shade700),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                        onSelected: (value) {
                          if (value == 'delete') {
                            ref.read(todoProvider.notifier).removeTodo(todo.id);
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTodoDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }
}