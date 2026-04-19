import 'package:flutter/material.dart';
import '../../../../shared/repositories/task_repository.dart';
import '../../../../shared/services/api_client.dart';
import 'package:dofirst/features/tasks/presentation/task_list/task_list_view_model.dart';

class UpcomingTask {
  final String id;
  final String title;
  final DateTime? deadline;
  final Color dotColor;

  UpcomingTask({
    required this.id,
    required this.title,
    required this.deadline,
    required this.dotColor,
  });

  /// Dynamically computed time text — always fresh when accessed
  String get time => TaskItem.formatDeadline(deadline);
}

class HomeViewModel extends ChangeNotifier {
  final TaskRepository _taskRepo = TaskRepository();

  String _userName = '';
  int _tasksDone = 0;
  int _totalTasks = 0;

  // Hero task
  String? _heroTaskId;
  String _heroTaskTitle = '';
  DateTime? _heroTaskDeadline;
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
  /// Dynamically computed — always fresh when accessed
  String get heroTaskTime => TaskItem.formatDeadline(_heroTaskDeadline);
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
    _loadFromCache().then((_) => loadDashboard());
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

  /// Called by the home page timer to trigger UI rebuild for countdown updates
  void refreshCountdowns() {
    notifyListeners();
  }

  /// Load cached dashboard data for instant display (no network delay)
  Future<void> _loadFromCache() async {
    try {
      final cached = await ApiClient.getCachedData('cached_dashboard');
      if (cached == null) return;

      final data = cached as Map<String, dynamic>;
      _populateFromData(data);
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      // Cache miss or corrupt — silently continue to fetch from API
    }
  }

  /// Populate fields from dashboard data (used by both cache and API)
  void _populateFromData(Map<String, dynamic> data) {
    _userName = data['userName'] as String? ?? 'User';
    _totalTasks = data['totalTasks'] as int? ?? 0;

    final hero = data['heroTask'] as Map<String, dynamic>?;
    if (hero != null) {
      _heroTaskId = hero['id'] as String;
      _heroTaskTitle = hero['title'] as String? ?? '';
      _heroTaskScore = (hero['score'] as num?)?.toDouble() ?? 0;
      _heroTaskTags = (hero['tags'] as List<dynamic>?)?.cast<String>() ?? [];
      final deadlineStr = hero['deadline'] as String?;
      _heroTaskDeadline = deadlineStr != null ? DateTime.tryParse(deadlineStr) : null;
    } else {
      _heroTaskId = null;
      _heroTaskTitle = 'No tasks yet';
      _heroTaskDeadline = null;
      _heroTaskScore = 0;
      _heroTaskTags = [];
    }

    final upcoming = data['upcomingTasks'] as List<dynamic>? ?? [];
    _upcomingTasks = upcoming.map((t) {
      final task = t as Map<String, dynamic>;
      final deadlineStr = task['deadline'] as String?;
      return UpcomingTask(
        id: task['id'] as String,
        title: task['title'] as String? ?? '',
        deadline: deadlineStr != null ? DateTime.tryParse(deadlineStr) : null,
        dotColor: _priorityColor(task['priority'] as String?),
      );
    }).toList();
  }

  Future<void> loadDashboard() async {
    // Only show loading indicator if we have no cached data
    if (_heroTaskId == null && _upcomingTasks.isEmpty) {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _taskRepo.getDashboard();
      _populateFromData(data);

      // Cache the response for next app launch
      await ApiClient.cacheData('cached_dashboard', data);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load dashboard';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _userName = '';
    _tasksDone = 0;
    _totalTasks = 0;
    _heroTaskId = null;
    _heroTaskTitle = '';
    _heroTaskDeadline = null;
    _heroTaskScore = 0;
    _heroTaskTags = [];
    _upcomingTasks = [];
    _isLoading = true;
    _errorMessage = null;
    _currentTabIndex = 0;
    notifyListeners();
  }
}
