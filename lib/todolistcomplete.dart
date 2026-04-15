import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advanced Todo App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Roboto',
      ),
      home: const TodoHomePage(),
    );
  }
}

class Todo {
  final String id;
  String title;
  final DateTime createdAt;
  bool isDone;
  double opacity;

  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
    this.opacity = 1.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage>
    with TickerProviderStateMixin {
  final List<Todo> _todos = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _fabController;
  late Animation<double> _fabScale;
  late AnimationController _progressController;

  Map<int, Color> _taskColors = {};
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadSampleData();
  }

  void _initControllers() {
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fabScale = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutBack,
    );
    _fabController.forward();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _loadSampleData() {
    // Optional: Add sample data for demonstration
    // Remove this in production
    if (_todos.isEmpty) {
      _todos.addAll([
        Todo(id: '1', title: 'Welcome to Advanced Todo! ✨', createdAt: DateTime.now().subtract(const Duration(days: 1))),
        Todo(id: '2', title: 'Tap to mark complete ✅', createdAt: DateTime.now().subtract(const Duration(hours: 5))),
        Todo(id: '3', title: 'Double tap to delete 🗑️', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
        Todo(id: '4', title: 'Long press for options 🎯', createdAt: DateTime.now()),
      ]);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _fabController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _addTask(String text) {
    if (text.trim().isEmpty) return;

    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: text.trim(),
    );

    setState(() {
      _todos.insert(0, newTodo);
    });

    _controller.clear();
    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task added: ${text.trim()}'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteTask(int index) async {
    final deletedTodo = _todos[index];
    setState(() {
      _todos.removeAt(index);
    });

    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: ${deletedTodo.title}'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _todos.insert(index, deletedTodo);
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleDone(int index) async {
    if (_todos[index].isDone) {
      // Restore opacity
      setState(() {
        _todos[index].isDone = false;
        _todos[index].opacity = 1.0;
      });
    } else {
      // Animate fade out
      for (double i = 1.0; i >= 0.0; i -= 0.05) {
        await Future.delayed(const Duration(milliseconds: 10));
        if (!mounted) return;
        setState(() {
          _todos[index].opacity = i;
        });
      }
      setState(() {
        _todos[index].isDone = true;
        _todos[index].opacity = 1.0;
      });
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Add New Task",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "What needs to be done?",
                      prefixIcon: const Icon(Icons.edit_note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: _addTask,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _addTask(_controller.text),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Add Task'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      _focusNode.unfocus();
    });
  }

  Color _getTaskColor(int index, bool isDone) {
    if (isDone) return Colors.green[100]!;
    if (!_taskColors.containsKey(index)) {
      _taskColors[index] = Color.fromARGB(
        255,
        100 + _random.nextInt(100),
        100 + _random.nextInt(100),
        200 + _random.nextInt(55),
      );
    }
    return _taskColors[index]!;
  }

  void _showOptionsDialog(int index, Todo todo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.indigo),
                title: const Text('Edit Task'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(index, todo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Task'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteTask(index);
                },
              ),
              ListTile(
                leading: Icon(
                  todo.isDone ? Icons.radio_button_unchecked : Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text(todo.isDone ? 'Mark as Incomplete' : 'Mark as Complete'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleDone(index);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(int index, Todo todo) {
    final editController = TextEditingController(text: todo.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Update your task...',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                setState(() {
                  _todos[index].title = value.trim();
                });
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  setState(() {
                    _todos[index].title = editController.text.trim();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task updated!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTodoItem(Todo todo, int index) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: todo.opacity,
      child: Dismissible(
        key: Key(todo.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
        ),
        onDismissed: (_) => _deleteTask(index),
        child: GestureDetector(
          onTap: () => _toggleDone(index),
          onDoubleTap: () => _deleteTask(index),
          onLongPress: () => _showOptionsDialog(index, todo),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
              color: _getTaskColor(index, todo.isDone),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: todo.isDone
                          ? const Icon(Icons.check_circle,
                          key: ValueKey("done"),
                          color: Colors.green,
                          size: 28)
                          : const Icon(Icons.radio_button_unchecked,
                          key: ValueKey("not_done"),
                          color: Colors.grey,
                          size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: todo.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: todo.isDone ? Colors.grey[600] : Colors.black87,
                            ),
                          ),
                          if (todo.createdAt != null)
                            Text(
                              _formatDate(todo.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.drag_handle, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildStatsBar() {
    final totalTasks = _todos.length;
    final completedTasks = _todos.where((todo) => todo.isDone).length;
    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    _progressController.animateTo(progress, duration: const Duration(milliseconds: 500));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '$completedTasks/$totalTasks tasks',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_todos.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: [
        _buildStatsBar(),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: _todos.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _todos.removeAt(oldIndex);
                _todos.insert(newIndex, item);

                // Rebuild color mapping
                _taskColors.clear();
              });
            },
            itemBuilder: (context, index) {
              return Container(
                key: Key(_todos[index].id),
                child: _buildTodoItem(_todos[index], index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No tasks yet!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the + button to add your first task",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Advanced Todo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_todos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Tasks'),
                    content: const Text('Are you sure you want to delete all tasks?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _todos.clear();
                            _taskColors.clear();
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All tasks cleared!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Clear all tasks',
            ),
        ],
      ),
      body: _buildList(),
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: FloatingActionButton.extended(
          onPressed: _showAddDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Task'),
          tooltip: 'Add new task',
        ),
      ),
    );
  }
}
