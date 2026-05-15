import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../shared/services/focus_notification_service.dart';
import '../../../../shared/repositories/focus_repository.dart';

class FocusSessionViewModel extends ChangeNotifier {
  static const int _focusMinutes = 25;
  static const int _breakMinutes = 5;
  
  int _remainingSeconds = _focusMinutes * 60;
  bool _isRunning = false;
  bool _isBreakMode = false;
  Timer? _timer;

  final FocusNotificationService _notificationService = FocusNotificationService();
  final FocusRepository _focusRepo = FocusRepository();

  /// Optional: the current task being focused on
  String? currentTaskId;

  /// Tracks elapsed time for the current focus session
  int _elapsedSeconds = 0;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isBreakMode => _isBreakMode;
  
  String get timeString {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    final totalSeconds = (_isBreakMode ? _breakMinutes : _focusMinutes) * 60;
    return 1 - (_remainingSeconds / totalSeconds);
  }

  FocusSessionViewModel() {
    _notificationService.init();
  }

  void toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _isRunning = true;
    WakelockPlus.enable(); // Keep screen on
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _elapsedSeconds++;
        notifyListeners();
      } else {
        _timer?.cancel();
        if (!_isBreakMode) {
          // Focus session finished → record to API + notify + switch to break mode
          _recordSession('focus');
          _notificationService.notifyFocusComplete();
          _isBreakMode = true;
          _remainingSeconds = _breakMinutes * 60;
          _elapsedSeconds = 0;
          _startTimer(); // Auto-start break
        } else {
          // Break finished → record to API + notify + switch back to focus mode
          _recordSession('break');
          _notificationService.notifyBreakComplete();
          _isBreakMode = false;
          _remainingSeconds = _focusMinutes * 60;
          _elapsedSeconds = 0;
          _startTimer(); // Auto-start next focus session
        }
      }
    });
  }

  void _pauseTimer() {
    _isRunning = false;
    _timer?.cancel();
    WakelockPlus.disable(); // Allow screen to dim
    notifyListeners();
  }

  void stopTimer() {
    // Record partial session if meaningful (>= 1 minute)
    if (_elapsedSeconds >= 60) {
      _recordSession(_isBreakMode ? 'break' : 'focus');
    }
    _pauseTimer();
    _isBreakMode = false;
    _remainingSeconds = _focusMinutes * 60;
    _elapsedSeconds = 0;
    notifyListeners();
  }

  /// Record the completed session to the backend API.
  Future<void> _recordSession(String type) async {
    final minutes = (_elapsedSeconds / 60).ceil();
    if (minutes <= 0) return;

    try {
      await _focusRepo.recordSession(
        taskId: currentTaskId,
        durationMinutes: minutes,
        sessionType: type,
      );
    } catch (e) {
      // Don't disrupt the UI if recording fails — it's best-effort
      debugPrint('Failed to record focus session: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable(); // Ensure screen dimming is restored
    super.dispose();
  }
}
