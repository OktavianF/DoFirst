import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../shared/services/focus_notification_service.dart';
import '../../../../shared/services/user_preferences_service.dart';

enum FocusExitDecision { allow, warn, strictBlocked }

class FocusSessionViewModel extends ChangeNotifier with WidgetsBindingObserver {
  static const int _defaultFocusMinutes = 25;
  static const int _defaultBreakMinutes = 5;

  int _focusMinutes = _defaultFocusMinutes;
  int _breakMinutes = _defaultBreakMinutes;

  int _remainingSeconds = _defaultFocusMinutes * 60;
  bool _isRunning = false;
  bool _isBreakMode = false;
  bool _warningMode = true;
  bool _strictMode = false;
  bool _strictStopTriggered = false;

  DateTime? _targetEndAt;
  Timer? _timer;

  final FocusNotificationService _notificationService = FocusNotificationService();

  int get focusMinutes => _focusMinutes;
  int get breakMinutes => _breakMinutes;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isBreakMode => _isBreakMode;
  bool get warningMode => _warningMode;
  bool get strictMode => _strictMode;
  bool get strictStopTriggered => _strictStopTriggered;

  String get timeString {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    final totalSeconds = (_isBreakMode ? breakMinutes : focusMinutes) * 60;
    if (totalSeconds <= 0) return 0;
    return 1 - (_remainingSeconds / totalSeconds);
  }

  FocusSessionViewModel() {
    WidgetsBinding.instance.addObserver(this);
    _safeInitNotifications();
    _loadSavedPreferences();
  }

  Future<void> _safeInitNotifications() async {
    try {
      await _notificationService.init();
    } catch (_) {
      // Ignore notification init failures in unsupported environments.
    }
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final savedFocusMinutes = await UserPreferencesService.getFocusMinutes();
      final savedBreakMinutes = await UserPreferencesService.getBreakMinutes();

      var changed = false;

      if (savedFocusMinutes != null) {
        final normalized = savedFocusMinutes.clamp(5, 180);
        if (_focusMinutes != normalized) {
          _focusMinutes = normalized;
          changed = true;
        }
        if (!_isRunning && !_isBreakMode) {
          _remainingSeconds = _focusMinutes * 60;
        }
      }

      if (savedBreakMinutes != null) {
        final normalized = savedBreakMinutes.clamp(1, 60);
        if (_breakMinutes != normalized) {
          _breakMinutes = normalized;
          changed = true;
        }
        if (!_isRunning && _isBreakMode) {
          _remainingSeconds = _breakMinutes * 60;
        }
      }

      if (changed) {
        notifyListeners();
      }
    } catch (_) {
      // Ignore persistence failures and keep defaults.
    }
  }

  void setFocusMinutes(int minutes) {
    final normalized = minutes.clamp(5, 180);
    if (_focusMinutes == normalized) return;
    _focusMinutes = normalized;
    unawaited(UserPreferencesService.saveFocusMinutes(normalized));

    if (!_isRunning && !_isBreakMode) {
      _remainingSeconds = _focusMinutes * 60;
    }
    notifyListeners();
  }

  void setBreakMinutes(int minutes) {
    final normalized = minutes.clamp(1, 60);
    if (_breakMinutes == normalized) return;
    _breakMinutes = normalized;
    unawaited(UserPreferencesService.saveBreakMinutes(normalized));

    if (!_isRunning && _isBreakMode) {
      _remainingSeconds = _breakMinutes * 60;
    }
    notifyListeners();
  }

  void setWarningMode(bool enabled) {
    _warningMode = enabled;
    notifyListeners();
  }

  void setStrictMode(bool enabled) {
    _strictMode = enabled;
    notifyListeners();
  }

  FocusExitDecision evaluateExitDecision() {
    if (!_isRunning) return FocusExitDecision.allow;
    if (_strictMode) return FocusExitDecision.strictBlocked;
    if (_warningMode) return FocusExitDecision.warn;
    return FocusExitDecision.allow;
  }

  void clearStrictStopFlag() {
    if (!_strictStopTriggered) return;
    _strictStopTriggered = false;
    notifyListeners();
  }

  void toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) {
      _remainingSeconds = (_isBreakMode ? _breakMinutes : _focusMinutes) * 60;
    }

    _timer?.cancel();
    _isRunning = true;
    _targetEndAt = DateTime.now().add(Duration(seconds: _remainingSeconds));
    WakelockPlus.enable();
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _syncRemainingFromTarget();
      if (_remainingSeconds <= 0) {
        _handlePeriodComplete();
      } else {
        notifyListeners();
      }
    });
  }

  void _pauseTimer() {
    _isRunning = false;
    _syncRemainingFromTarget();
    _targetEndAt = null;
    _timer?.cancel();
    WakelockPlus.disable();
    notifyListeners();
  }

  void _syncRemainingFromTarget() {
    final target = _targetEndAt;
    if (target == null) return;

    final diff = target.difference(DateTime.now()).inSeconds;
    _remainingSeconds = diff > 0 ? diff : 0;
  }

  Future<void> _handlePeriodComplete() async {
    _timer?.cancel();

    if (!_isBreakMode) {
      try {
        await _notificationService.notifyFocusComplete();
      } catch (_) {
        // Ignore notification failures.
      }
      _isBreakMode = true;
      _remainingSeconds = _breakMinutes * 60;
    } else {
      try {
        await _notificationService.notifyBreakComplete();
      } catch (_) {
        // Ignore notification failures.
      }
      _isBreakMode = false;
      _remainingSeconds = _focusMinutes * 60;
    }

    if (_isRunning) {
      _startTimer();
    } else {
      notifyListeners();
    }
  }

  void stopTimer() {
    _pauseTimer();
    _isBreakMode = false;
    _remainingSeconds = _focusMinutes * 60;
    _strictStopTriggered = false;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isRunning) {
        _syncRemainingFromTarget();
        if (_remainingSeconds <= 0) {
          _handlePeriodComplete();
        } else {
          notifyListeners();
        }
      }
      return;
    }

    if (_isRunning && _strictMode && (state == AppLifecycleState.inactive || state == AppLifecycleState.paused)) {
      _strictStopTriggered = true;
      stopTimer();
      _notificationService
          .notify(
            title: 'Strict Mode Stopped Session',
            body: 'Timer dihentikan karena aplikasi ditinggalkan saat strict mode aktif.',
          )
          .catchError((_) => null);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _targetEndAt = null;
    WakelockPlus.disable();
    super.dispose();
  }
}
