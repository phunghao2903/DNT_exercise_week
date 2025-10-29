import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
      home: const TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  static const String _storageKey = 'todo_items';

  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  List<TodoTask> _tasks = <TodoTask>[];
  SharedPreferences? _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<TodoTask> loadedTasks = <TodoTask>[];
    final String? storedTasks = prefs.getString(_storageKey);

    if (storedTasks != null) {
      try {
        final List<dynamic> decoded = jsonDecode(storedTasks) as List<dynamic>;
        for (final dynamic entry in decoded) {
          if (entry is Map<String, dynamic>) {
            loadedTasks.add(TodoTask.fromMap(entry));
          }
        }
      } catch (error) {
        debugPrint('Failed to decode stored tasks: $error');
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _prefs = prefs;
      _tasks = loadedTasks;
      _isLoading = false;
    });
  }

  Future<void> _saveTasks() async {
    final SharedPreferences prefs = _prefs ??=
        await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _tasks.map((TodoTask task) => task.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> _addTask(String title) async {
    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }

    final TodoTask newTask = TodoTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: trimmedTitle,
      isDone: false,
      createdAt: DateTime.now(),
    );

    setState(() {
      _tasks = <TodoTask>[..._tasks, newTask];
    });

    await _saveTasks();
  }

  Future<void> _toggleTaskStatus(TodoTask task) async {
    setState(() {
      _tasks = _tasks
          .map(
            (TodoTask current) => current.id == task.id
                ? current.copyWith(isDone: !current.isDone)
                : current,
          )
          .toList();
    });
    await _saveTasks();
  }

  Future<void> _deleteTask(TodoTask task) async {
    setState(() {
      _tasks = _tasks
          .where((TodoTask current) => current.id != task.id)
          .toList();
    });
    await _saveTasks();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${task.title}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddTaskSheet() {
    _inputController.clear();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _inputController,
                focusNode: _inputFocusNode,
                autofocus: true,
                maxLength: 60,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  hintText: 'e.g. Buy groceries',
                  counterText: '',
                ),
                onSubmitted: (_) => _submitNewTask(),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _submitNewTask,
                icon: const Icon(Icons.check),
                label: const Text('Save task'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(_inputController.clear);
  }

  Future<void> _submitNewTask() async {
    final String value = _inputController.text;
    if (value.trim().isEmpty) {
      _inputFocusNode.requestFocus();
      return;
    }

    await _addTask(value);

    if (!mounted) {
      return;
    }

    Navigator.of(context).maybePop();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tasks.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      itemCount: _tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final TodoTask task = _tasks[index];
        return Dismissible(
          key: ValueKey<String>(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          onDismissed: (_) => _deleteTask(task),
          child: _TaskTile(
            task: task,
            onToggle: () => _toggleTaskStatus(task),
            onDelete: () => _deleteTask(task),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.check_circle_outline,
            size: 72,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text('No tasks yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first task.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int completedCount = _tasks
        .where((TodoTask task) => task.isDone)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: <Widget>[
            _HeaderSummary(total: _tasks.length, completed: completedCount),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }
}

class TodoTask {
  const TodoTask({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
  });

  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  TodoTask copyWith({String? title, bool? isDone}) {
    return TodoTask(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TodoTask.fromMap(Map<String, dynamic> map) {
    return TodoTask(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      isDone: map['isDone'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  const _HeaderSummary({required this.total, required this.completed});

  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Total', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                '$total',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text('Completed', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                '$completed',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  final TodoTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? baseStyle = theme.textTheme.titleMedium;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          shape: const CircleBorder(),
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: baseStyle?.copyWith(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone
                ? theme.colorScheme.outline
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          'Created ${_formatCreatedAt(task.createdAt)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }

  String _formatCreatedAt(DateTime date) {
    final DateTime now = DateTime.now();
    if (now.difference(date).inDays >= 1) {
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}';
    }
    final int hours = now.difference(date).inHours;
    if (hours >= 1) {
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
    final int minutes = now.difference(date).inMinutes;
    if (minutes >= 1) {
      return '$minutes min${minutes == 1 ? '' : 's'} ago';
    }
    return 'Just now';
  }
}
