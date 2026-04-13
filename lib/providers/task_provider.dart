import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  Category? _selectedCategory;
  Priority? _selectedPriority;
  String _searchQuery = '';
  bool _showCompleted = true;
  final _uuid = const Uuid();

  List<Task> get tasks => _filteredTasks;
  Category? get selectedCategory => _selectedCategory;
  Priority? get selectedPriority => _selectedPriority;
  String get searchQuery => _searchQuery;
  bool get showCompleted => _showCompleted;

  List<Task> get _filteredTasks {
    return _tasks.where((task) {
      if (!_showCompleted && task.isCompleted) return false;
      if (_selectedCategory != null && task.category != _selectedCategory)
        return false;
      if (_selectedPriority != null && task.priority != _selectedPriority)
        return false;
      if (_searchQuery.isNotEmpty &&
          !task.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        return false;
      return true;
    }).toList()
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        final priorityCompare = b.priority.index.compareTo(a.priority.index);
        if (priorityCompare != 0) return priorityCompare;
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.isCompleted).length;
  int get pendingTasks => _tasks.where((t) => !t.isCompleted).length;
  int get overdueTasks => _tasks.where((t) => t.isOverdue).length;

  Map<Category, int> get tasksByCategory {
    final map = <Category, int>{};
    for (final cat in Category.values) {
      map[cat] = _tasks.where((t) => t.category == cat && !t.isCompleted).length;
    }
    return map;
  }

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      _tasks = decoded.map((e) => Task.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  void addTask({
    required String title,
    String? description,
    Priority priority = Priority.medium,
    Category category = Category.personal,
    DateTime? dueDate,
    bool hasReminder = false,
  }) {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      category: category,
      dueDate: dueDate,
      hasReminder: hasReminder,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      _saveTasks();
      notifyListeners();
    }
  }

  void setCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setPriority(Priority? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  void clearCompleted() {
    _tasks.removeWhere((t) => t.isCompleted);
    _saveTasks();
    notifyListeners();
  }
}
