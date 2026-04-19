import 'package:flutter/material.dart';
import '../../../../shared/repositories/task_repository.dart';
import '../../../../shared/services/api_client.dart';

class TaskItem {
  final String id;
  final String title;
  final double score;
  final String priority;
  final String? description;
  final DateTime? deadline;

  TaskItem({
    required this.id,
    required this.title,
    required this.score,
    required this.priority,
    this.description,
    this.deadline,
  });

  /// Format deadline as a human-readable countdown including minutes.
  /// Recompute this every time you need a fresh value for realtime updates.
  String get timeText => formatDeadline(deadline);

  /// Static helper so other widgets can also format deadlines.
  static String formatDeadline(DateTime? dl) {
    if (dl == null) return 'No deadline';

    final diff = dl.difference(DateTime.now());
    if (diff.isNegative) return 'Overdue';

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    if (days > 0) {
      return hours > 0 ? '${days}d ${hours}h left' : '${days}d left';
    }
    if (hours > 0) {
      return '${hours}h ${minutes}m left';
    }
    if (minutes > 0) {
      return '${minutes}m left';
    }
    return 'Due soon';
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final deadlineStr = json['deadline'] as String?;
    DateTime? deadline;
    if (deadlineStr != null) {
      deadline = DateTime.tryParse(deadlineStr);
    }

    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      priority: (json['priority'] as String?)?.toUpperCase() ?? 'MEDIUM',
      description: json['description'] as String?,
      deadline: deadline,
    );
  }
}

enum TaskFilter { all, high, medium, low }

enum TaskSort { scoreDesc, scoreAsc, newest, oldest }

class TaskListViewModel extends ChangeNotifier {
  final TaskRepository _taskRepo = TaskRepository();

  List<TaskItem> _allTasks = [];
  String _searchQuery = '';
  TaskFilter _filter = TaskFilter.all;
  TaskSort _sort = TaskSort.scoreDesc;
  bool _isLoading = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TaskListViewModel() {
    _loadFromCache().then((_) => loadTasks());
  }

  /// Load cached tasks for instant display (no network delay)
  Future<void> _loadFromCache() async {
    try {
      final cached = await ApiClient.getCachedData('cached_tasks');
      if (cached == null) return;

      final tasksList = cached as List<dynamic>;
      _allTasks = tasksList
          .map((json) => TaskItem.fromJson(json as Map<String, dynamic>))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      // Cache miss or corrupt — silently continue to fetch from API
    }
  }

  Future<void> loadTasks() async {
    // Only show loading indicator if we have no cached data
    if (_allTasks.isEmpty) {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final tasksData = await _taskRepo.getTasks();
      _allTasks = tasksData.map((json) => TaskItem.fromJson(json)).toList();

      // Cache the response for next app launch
      await ApiClient.cacheData('cached_tasks', tasksData);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load tasks';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TaskItem> get _filteredTasks {
    var tasks = _allTasks.where((task) {
      if (_searchQuery.isNotEmpty) {
        if (!task.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      switch (_filter) {
        case TaskFilter.all:
          return true;
        case TaskFilter.high:
          return task.priority == 'HIGH';
        case TaskFilter.medium:
          return task.priority == 'MEDIUM';
        case TaskFilter.low:
          return task.priority == 'LOW';
      }
    }).toList();

    switch (_sort) {
      case TaskSort.scoreDesc:
        tasks.sort((a, b) => b.score.compareTo(a.score));
        break;
      case TaskSort.scoreAsc:
        tasks.sort((a, b) => a.score.compareTo(b.score));
        break;
      case TaskSort.newest:
        tasks = tasks.reversed.toList();
        break;
      case TaskSort.oldest:
        break;
    }

    return tasks;
  }

  List<TaskItem> get highPriorityTasks =>
      _filteredTasks.where((t) => t.priority == 'HIGH').toList();

  List<TaskItem> get mediumPriorityTasks =>
      _filteredTasks.where((t) => t.priority == 'MEDIUM').toList();

  List<TaskItem> get lowPriorityTasks =>
      _filteredTasks.where((t) => t.priority == 'LOW').toList();

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  String get currentFilterLabel {
    switch (_filter) {
      case TaskFilter.all:
        return 'All Tasks';
      case TaskFilter.high:
        return 'High Only';
      case TaskFilter.medium:
        return 'Medium Only';
      case TaskFilter.low:
        return 'Low Only';
    }
  }

  String get currentSortLabel {
    switch (_sort) {
      case TaskSort.scoreDesc:
        return 'Highest Score';
      case TaskSort.scoreAsc:
        return 'Lowest Score';
      case TaskSort.newest:
        return 'Newest First';
      case TaskSort.oldest:
        return 'Oldest First';
    }
  }

  void toggleFilter() {
    final values = TaskFilter.values;
    final nextIndex = (values.indexOf(_filter) + 1) % values.length;
    _filter = values[nextIndex];
    notifyListeners();
  }

  void toggleSort() {
    final values = TaskSort.values;
    final nextIndex = (values.indexOf(_sort) + 1) % values.length;
    _sort = values[nextIndex];
    notifyListeners();
  }

  Future<void> completeTask(String taskId) async {
    try {
      await _taskRepo.completeTask(taskId);
      _allTasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  void clear() {
    _allTasks = [];
    _searchQuery = '';
    _filter = TaskFilter.all;
    _sort = TaskSort.scoreDesc;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }
}
