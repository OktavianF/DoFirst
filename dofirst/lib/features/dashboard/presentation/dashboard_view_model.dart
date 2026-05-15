import 'package:flutter/foundation.dart';
import '../../../../shared/repositories/task_repository.dart';
import '../../../../shared/services/api_client.dart';

class DashboardViewModel extends ChangeNotifier {
  final TaskRepository _taskRepo = TaskRepository();

  String _userName = 'User';
  int _totalTasks = 0;
  int _completedTasksCount = 0;
  int _highPriorityCount = 0;
  int _averageFocusMinutes = 0;
  int _totalFocusMinutes = 0;
  int _unreadNotifications = 0;
  Map<String, dynamic>? _heroTask;
  List<Map<String, dynamic>> _upcomingTasks = [];
  List<Map<String, dynamic>> _recentHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get userName => _userName;
  int get totalTasks => _totalTasks;
  int get completedTasksCount => _completedTasksCount;
  int get highPriorityCount => _highPriorityCount;
  int get averageFocusMinutes => _averageFocusMinutes;
  int get totalFocusMinutes => _totalFocusMinutes;
  int get unreadNotifications => _unreadNotifications;
  Map<String, dynamic>? get heroTask => _heroTask;
  List<Map<String, dynamic>> get upcomingTasks => _upcomingTasks;
  List<Map<String, dynamic>> get recentHistory => _recentHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Format average focus as human-readable string
  String get averageFocusFormatted {
    if (_averageFocusMinutes >= 60) {
      final hours = _averageFocusMinutes / 60;
      return '${hours.toStringAsFixed(1)}h';
    }
    return '${_averageFocusMinutes}m';
  }

  /// Total focus as hours string
  String get totalFocusFormatted {
    if (_totalFocusMinutes >= 60) {
      final hours = _totalFocusMinutes / 60;
      return '${hours.toStringAsFixed(1)}h';
    }
    return '${_totalFocusMinutes}m';
  }

  DashboardViewModel() {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _taskRepo.getDashboard();

      _userName = data['userName'] as String? ?? 'User';
      _totalTasks = data['totalTasks'] as int? ?? 0;
      _completedTasksCount = data['completedTasksCount'] as int? ?? 0;
      _highPriorityCount = data['highPriorityCount'] as int? ?? 0;
      _averageFocusMinutes = data['averageFocusMinutes'] as int? ?? 0;
      _totalFocusMinutes = data['totalFocusMinutes'] as int? ?? 0;
      _unreadNotifications = data['unreadNotifications'] as int? ?? 0;
      _heroTask = data['heroTask'] as Map<String, dynamic>?;

      final upcoming = data['upcomingTasks'] as List<dynamic>? ?? [];
      _upcomingTasks = upcoming.cast<Map<String, dynamic>>();

      final history = data['recentHistory'] as List<dynamic>? ?? [];
      _recentHistory = history.cast<Map<String, dynamic>>();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load dashboard';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    _userName = 'User';
    _totalTasks = 0;
    _completedTasksCount = 0;
    _highPriorityCount = 0;
    _averageFocusMinutes = 0;
    _totalFocusMinutes = 0;
    _unreadNotifications = 0;
    _heroTask = null;
    _upcomingTasks = [];
    _recentHistory = [];
    _errorMessage = null;
    notifyListeners();
  }
}
