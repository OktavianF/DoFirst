import 'package:flutter/material.dart';
import '../../../../shared/repositories/task_repository.dart';
import '../../../../shared/services/api_client.dart';

class TaskItem {
  final String id;
  final String title;
  final double score;
  final String timeText;
  final String priority;
  final String? description;

  TaskItem({
    required this.id,
    required this.title,
    required this.score,
    required this.timeText,
    required this.priority,
    this.description,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final deadline = json['deadline'] as String?;
    String timeText = 'No deadline';
    if (deadline != null) {
      final dt = DateTime.tryParse(deadline);
      if (dt != null) {
        final diff = dt.difference(DateTime.now());
        if (diff.inDays > 0) {
          timeText = '${diff.inDays}d left';
        } else if (diff.inHours > 0) {
          timeText = '${diff.inHours}h left';
        } else if (diff.isNegative) {
          timeText = 'Overdue';
        } else {
          timeText = 'Due soon';
        }
      }
    }

    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      timeText: timeText,
      priority: (json['priority'] as String?)?.toUpperCase() ?? 'MEDIUM',
      description: json['description'] as String?,
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
    loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tasksData = await _taskRepo.getTasks();
      _allTasks = tasksData.map((json) => TaskItem.fromJson(json)).toList();
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
