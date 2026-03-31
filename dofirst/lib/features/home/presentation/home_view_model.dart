import 'package:flutter/material.dart';
import '../../../../shared/repositories/task_repository.dart';
import '../../../../shared/services/api_client.dart';

class UpcomingTask {
  final String id;
  final String title;
  final String time;
  final Color dotColor;

  UpcomingTask({
    required this.id,
    required this.title,
    required this.time,
    required this.dotColor,
  });
}

class HomeViewModel extends ChangeNotifier {
  final TaskRepository _taskRepo = TaskRepository();

  String _userName = '';
  int _tasksDone = 0;
  int _totalTasks = 0;

  // Hero task
  String? _heroTaskId;
  String _heroTaskTitle = '';
  String _heroTaskTime = '';
  double _heroTaskScore = 0;
  List<String> _heroTaskTags = [];

  // Upcoming tasks
  List<UpcomingTask> _upcomingTasks = [];

  bool _isLoading = true;
  String? _errorMessage;
  int _currentTabIndex = 0;

  // Getters
  String get userName => _userName;
  int get tasksDone => _tasksDone;
  int get totalTasks => _totalTasks;

  bool get hasHeroTask => _heroTaskId != null;
  String? get heroTaskId => _heroTaskId;
  String get heroTaskTitle => _heroTaskTitle;
  String get heroTaskTime => _heroTaskTime;
  double get heroTaskScore => _heroTaskScore;
  List<String> get heroTaskTags => _heroTaskTags;

  List<UpcomingTask> get upcomingTasks => _upcomingTasks;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  HomeViewModel() {
    loadDashboard();
  }

  String _formatDeadline(String? deadline) {
    if (deadline == null) return 'No deadline';
    final dt = DateTime.tryParse(deadline);
    if (dt == null) return 'No deadline';

    final diff = dt.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    if (diff.isNegative) return 'Overdue';
    return 'Due soon';
  }

  Color _priorityColor(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFBA1A1A);
      case 'MEDIUM':
        return const Color(0xFFF59E0B);
      case 'LOW':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF777587);
    }
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _taskRepo.getDashboard();

      _userName = data['userName'] as String? ?? 'User';
      _totalTasks = data['totalTasks'] as int? ?? 0;

      final hero = data['heroTask'] as Map<String, dynamic>?;
      if (hero != null) {
        _heroTaskId = hero['id'] as String;
        _heroTaskTitle = hero['title'] as String? ?? '';
        _heroTaskScore = (hero['score'] as num?)?.toDouble() ?? 0;
        _heroTaskTags = (hero['tags'] as List<dynamic>?)?.cast<String>() ?? [];
        _heroTaskTime = _formatDeadline(hero['deadline'] as String?);
      } else {
        _heroTaskId = null;
        _heroTaskTitle = 'No tasks yet';
        _heroTaskTime = '';
        _heroTaskScore = 0;
        _heroTaskTags = [];
      }

      final upcoming = data['upcomingTasks'] as List<dynamic>? ?? [];
      _upcomingTasks = upcoming.map((t) {
        final task = t as Map<String, dynamic>;
        return UpcomingTask(
          id: task['id'] as String,
          title: task['title'] as String? ?? '',
          time: _formatDeadline(task['deadline'] as String?),
          dotColor: _priorityColor(task['priority'] as String?),
        );
      }).toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load dashboard';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
