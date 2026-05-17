import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../shared/services/focus_notification_service.dart';
import '../../../../shared/repositories/focus_repository.dart';
import '../../../../shared/repositories/settings_repository.dart';

class FocusSessionViewModel extends ChangeNotifier {
  // Dynamic durations — loaded from user settings
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _longBreakMinutes = 15;
  int _sessionsBeforeLongBreak = 4;
  int _completedSessions = 0;
  String _soundPreference = 'Chime';
  
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isBreakMode = false;
  Timer? _timer;

  final FocusNotificationService _notificationService = FocusNotificationService();
  final FocusRepository _focusRepo = FocusRepository();
  final SettingsRepository _settingsRepo = SettingsRepository();

  /// Optional: the current task being focused on
  String? currentTaskId;

  /// Tracks elapsed time for the current focus session
  int _elapsedSeconds = 0;

  /// Whether settings have been loaded
  bool _settingsLoaded = false;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isBreakMode => _isBreakMode;
  int get focusMinutes => _focusMinutes;
  int get breakMinutes => _breakMinutes;
  int get completedSessions => _completedSessions;
  bool get settingsLoaded => _settingsLoaded;
  
  String get timeString {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    final totalSeconds = _currentTotalSeconds;
    return 1 - (_remainingSeconds / totalSeconds);
  }

  int get _currentTotalSeconds {
    if (_isBreakMode) {
      // Use long break if we've completed enough sessions
      if (_completedSessions > 0 && _completedSessions % _sessionsBeforeLongBreak == 0) {
        return _longBreakMinutes * 60;
      }
      return _breakMinutes * 60;
    }
    return _focusMinutes * 60;
  }

  FocusSessionViewModel() {
    _notificationService.init();
    loadSettings();
  }

  /// Load focus/break durations from user settings (API)
  Future<void> loadSettings() async {
    try {
      final data = await _settingsRepo.getSettings();
      _focusMinutes = data['focusDuration'] as int? ?? data['focus_duration'] as int? ?? 25;
      _breakMinutes = data['shortBreak'] as int? ?? data['short_break'] as int? ?? 5;
      _longBreakMinutes = data['longBreak'] as int? ?? data['long_break'] as int? ?? 15;
      _sessionsBeforeLongBreak = data['sessionsBeforeLongBreak'] as int? ?? data['sessions_before_long_break'] as int? ?? 4;
      _soundPreference = data['sound'] as String? ?? 'Chime';

      // Reset timer to new focus duration if not currently running
      if (!_isRunning) {
        _remainingSeconds = _focusMinutes * 60;
      }
      _settingsLoaded = true;
      notifyListeners();
    } catch (e) {
      // Fallback to defaults if settings fail to load
      _settingsLoaded = true;
      debugPrint('Failed to load focus settings: $e');
      notifyListeners();
    }
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
          _completedSessions++;
          _recordSession('focus');
          _notificationService.notifyFocusComplete();
          _isBreakMode = true;
          // Use long break if completed enough sessions
          if (_completedSessions % _sessionsBeforeLongBreak == 0) {
            _remainingSeconds = _longBreakMinutes * 60;
          } else {
            _remainingSeconds = _breakMinutes * 60;
          }
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
    _completedSessions = 0;
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
