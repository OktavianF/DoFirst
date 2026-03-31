import 'package:flutter/foundation.dart';
import '../../../../shared/repositories/task_repository.dart';
import '../../../../shared/services/api_client.dart';

class TaskInputViewModel extends ChangeNotifier {
  final TaskRepository _taskRepo = TaskRepository();

  String _title = '';
  int _importance = 3;
  int _difficulty = 3;
  int _urgency = 3;
  String _deadline = 'Today';
  bool _isLoading = false;
  String? _errorMessage;

  String get title => _title;
  int get importance => _importance;
  int get difficulty => _difficulty;
  int get urgency => _urgency;
  String get deadline => _deadline;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isValid => _title.isNotEmpty;

  void updateTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void updateImportance(int value) {
    _importance = value;
    notifyListeners();
  }

  void updateDifficulty(int value) {
    _difficulty = value;
    notifyListeners();
  }

  void updateUrgency(int value) {
    _urgency = value;
    notifyListeners();
  }

  void updateDeadline(String value) {
    _deadline = value;
    notifyListeners();
  }

  Future<bool> saveTask() async {
    if (!isValid) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _taskRepo.createTask(
        title: _title,
        importance: _importance,
        difficulty: _difficulty,
        urgency: _urgency,
        deadline: _deadline,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create task. Is the server running?';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
