import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../shared/repositories/task_repository.dart';
import '../../../../shared/services/api_client.dart';

class EditTaskViewModel extends ChangeNotifier {
  final TaskRepository taskRepo = TaskRepository();

  String _title = '';
  String _description = '';
  String? _attachmentName;
  String? _attachmentPath;
  String? _existingFileUrl;
  bool _attachmentRemoved = false;
  int _importance = 3;
  int _difficulty = 3;
  int _urgency = 3;
  String _deadline = 'Today';
  bool _isLoading = false;
  String? _errorMessage;

  /// Stores the actual DateTime when a custom date/time is picked via calendar.
  DateTime? _customDeadlineDateTime;

  String get title => _title;
  String get description => _description;
  String? get attachmentName => _attachmentName;
  String? get existingFileUrl => _existingFileUrl;
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

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void updateAttachment(String? fileName, {String? filePath}) {
    _attachmentName = fileName;
    _attachmentPath = filePath;
    if (fileName == null) {
      _attachmentRemoved = true;
      _existingFileUrl = null;
    }
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
    // Clear custom datetime when switching to preset options
    if (['Today', 'Tomorrow', 'Next Week'].contains(value)) {
      _customDeadlineDateTime = null;
    }
    notifyListeners();
  }

  /// Set a custom deadline from calendar/time picker
  void updateCustomDeadline(String displayText, DateTime dateTime) {
    _deadline = displayText;
    _customDeadlineDateTime = dateTime;
    notifyListeners();
  }

  /// Convert the deadline selection to an ISO 8601 string with explicit UTC timezone (Z).
  /// This eliminates any timezone ambiguity when parsed by the Node.js backend.
  String? _resolveDeadlineToISO() {
    switch (_deadline) {
      case 'Today':
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc().toIso8601String();
      case 'Tomorrow':
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59).toUtc().toIso8601String();
      case 'Next Week':
        final nextWeek = DateTime.now().add(const Duration(days: 7));
        return DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 23, 59, 59).toUtc().toIso8601String();
      default:
        // Custom date/time from calendar picker
        if (_customDeadlineDateTime != null) {
          return _customDeadlineDateTime!.toUtc().toIso8601String();
        }
        return null;
    }
  }

  String? _taskId;
  
  void initFromTask(dynamic task) {
    if (_taskId != null) return; // already inited
    _taskId = task.id;
    _title = task.title;
    _description = task.description ?? '';

    // Load real values from TaskItem
    _importance = task.importance ?? 3;
    _difficulty = task.difficulty ?? 3;
    _urgency = task.urgency ?? 3;

    // Parse deadline
    if (task.deadline != null) {
      _customDeadlineDateTime = task.deadline;
      _deadline = 'Custom';
    } else {
      _deadline = 'Today';
    }

    // Load file attachment
    if (task.fileUrl != null) {
      _existingFileUrl = task.fileUrl;
      final uri = Uri.tryParse(task.fileUrl);
      _attachmentName = uri?.pathSegments.last ?? 'Attachment';
    }

    notifyListeners();
  }

  Future<bool> updateTask() async {
    if (!isValid) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = {
        'title': _title,
        'description': _description.isEmpty ? null : _description,
        'importance': _importance,
        'difficulty': _difficulty,
        'urgency': _urgency,
        'deadline': _resolveDeadlineToISO(),
      };
      
      // If user explicitly removed the attachment, clear it
      if (_attachmentRemoved && _attachmentPath == null) {
        payload['fileUrl'] = null;
      }
      
      await taskRepo.updateTask(_taskId!, payload);

      // Upload attachment if a new file was picked
      if (_attachmentPath != null) {
        try {
          await taskRepo.uploadTaskAttachment(_taskId!, File(_attachmentPath!));
        } catch (e) {
          debugPrint('Attachment upload failed: $e');
        }
      }

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
