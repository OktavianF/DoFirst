import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../shared/services/focus_notification_service.dart';

class FocusSessionViewModel extends ChangeNotifier {
  static const int _focusMinutes = 1;
  static const int _breakMinutes = 5;
  
  int _remainingSeconds = _focusMinutes * 60;
  bool _isRunning = false;
  bool _isBreakMode = false;
  Timer? _timer;

  final FocusNotificationService _notificationService = FocusNotificationService();

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
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        if (!_isBreakMode) {
          // Focus session finished → notify + switch to break mode
          _notificationService.notifyFocusComplete();
          _isBreakMode = true;
          _remainingSeconds = _breakMinutes * 60;
          _startTimer(); // Auto-start break
        } else {
          // Break finished → notify + switch back to focus mode
          _notificationService.notifyBreakComplete();
          _isBreakMode = false;
          _remainingSeconds = _focusMinutes * 60;
          _startTimer(); // Auto-start next focus session
        }
      }
    });
  }

  void _pauseTimer() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void stopTimer() {
    _pauseTimer();
    _isBreakMode = false;
    _remainingSeconds = _focusMinutes * 60;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
