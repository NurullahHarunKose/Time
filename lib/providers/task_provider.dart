import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
// Alias the Category import to avoid conflict with Flutter's Category annotation class if it exists, 
// though typically Category is not in material.dart. The error says it is conflicts with 'package:flutter/src/foundation/annotations.dart'.
// Let's hide Category from foundation/material just in case, or simpler: import model with alias.
import '../models/category_model.dart' as model;

// Remove explicit TaskPriority enum as we are moving to dynamic categories via Category model

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String categoryId; // Changed from TaskPriority
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.categoryId,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    // Migration logic for old data using priorities
    String catId = json['categoryId'] ?? 'default';
    if (json['categoryId'] == null && json['priority'] != null) {
      final int p = json['priority'];
      const map = [
        'urgent_important',     // 0
        'urgent_not_important', // 1
        'not_urgent_important', // 2
        'not_urgent_not_important' // 3
      ];
      if (p >= 0 && p < map.length) {
        catId = map[p];
      }
    }

    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      categoryId: catId,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<model.Category> _categories = [];
  DateTime? _selectedDate;
  final _prefs = SharedPreferences.getInstance();

  TaskProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadCategories();
    await _loadTasks();
  }

  List<Task> get tasks => _tasks;
  
  // Return all categories in storage
  List<model.Category> get allCategories => _categories;

  // Return only categories for the currently selected date, sorted by orderIndex
  List<model.Category> get categories {
    if (_selectedDate == null) return [];
    
    final dailyCategories = _categories.where((cat) => 
      cat.date.year == _selectedDate!.year && 
      cat.date.month == _selectedDate!.month && 
      cat.date.day == _selectedDate!.day
    ).toList();
    
    dailyCategories.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return dailyCategories;
  }

  DateTime? get selectedDate => _selectedDate;

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) => 
      task.date.year == date.year && 
      task.date.month == date.month && 
      task.date.day == date.day
    ).toList();
  }

  List<Task> getTasksByCategory(String categoryId) {
    return _tasks.where((task) => task.categoryId == categoryId).toList();
  }

  model.Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Category Management
  void addCategory(model.Category category) {
    // Yeni eklenen kategoriye, o günün son sırasını ata
    final existingCats = categories; // Getter is already filtered by date
    final newOrderIndex = existingCats.isNotEmpty 
        ? existingCats.map((c) => c.orderIndex).reduce((curr, next) => curr > next ? curr : next) + 1 
        : 0;

    final newCategory = model.Category(
      id: category.id,
      name: category.name,
      color: category.color,
      date: category.date,
      orderIndex: newOrderIndex,
    );

    _categories.add(newCategory);
    _saveCategories();
    notifyListeners();
  }

  void reorderCategories(int oldIndex, int newIndex) {
    if (_selectedDate == null) return;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final dailyCats = categories; // Sorted list
    final item = dailyCats.removeAt(oldIndex);
    dailyCats.insert(newIndex, item);

    // Update orderIndex for all categories in this day
    for (int i = 0; i < dailyCats.length; i++) {
        final cat = dailyCats[i];
        final indexInMainList = _categories.indexWhere((c) => c.id == cat.id);
        if (indexInMainList != -1) {
          _categories[indexInMainList] = model.Category(
            id: cat.id,
            name: cat.name,
            color: cat.color,
            date: cat.date,
            orderIndex: i, // New order
          );
        }
    }
    
    _saveCategories();
    notifyListeners();
  }

  void updateTaskCategory(String taskId, String newCategoryId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final oldTask = _tasks[taskIndex];
      _tasks[taskIndex] = Task(
        id: oldTask.id,
        title: oldTask.title,
        description: oldTask.description,
        date: oldTask.date,
        categoryId: newCategoryId,
        isCompleted: oldTask.isCompleted,
      );
      _saveTasks();
      notifyListeners();
    }
  }

  void removeCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    // Kategoriye ait görevleri de sil
    _tasks.removeWhere((task) => task.categoryId == id);
    
    _saveCategories();
    _saveTasks();
    notifyListeners();
  }

  // Task Management
  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _saveTasks();
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String id) {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    _saveTasks();
    notifyListeners();
  }

  // Persistence
  Future<void> _loadCategories() async {
    final prefs = await _prefs;
    final catsJson = prefs.getString('categories');
    if (catsJson != null) {
      final List<dynamic> decoded = jsonDecode(catsJson);
      _categories = decoded.map((item) => model.Category.fromJson(item)).toList();
    }
    
    // We removed default categories as requested
    notifyListeners();
  }

  Future<void> _saveCategories() async {
    final prefs = await _prefs;
    final catsJson = jsonEncode(_categories.map((c) => c.toJson()).toList());
    await prefs.setString('categories', catsJson);
  }

  Future<void> _loadTasks() async {
    final prefs = await _prefs;
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final tasksList = jsonDecode(tasksJson) as List;
      _tasks = tasksList.map((taskJson) => Task.fromJson(taskJson)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await _prefs;
    final tasksJson = jsonEncode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }
}


 