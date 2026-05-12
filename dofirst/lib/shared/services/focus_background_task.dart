import 'package:background_fetch/background_fetch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'focus_notification_service.dart';

/// Background task handler for monitoring focus timer while app is in background
class FocusBackgroundTask {
  static const String _timerTargetKey = 'focus_timer_target';
  static const String _timerIsBreakKey = 'focus_timer_is_break';
  static const String _timerIsRunningKey = 'focus_timer_is_running';

  static final FocusBackgroundTask _instance = FocusBackgroundTask._internal();

  factory FocusBackgroundTask() => _instance;

  FocusBackgroundTask._internal();

  late final FocusNotificationService _notificationService;
  bool _initialized = false;

  /// Initialize background fetch handler
  Future<void> init() async {
    if (_initialized) return;

    _notificationService = FocusNotificationService();
    await _notificationService.init();

    // Configure background fetch to check timer every 15 minutes
    // On iOS, this typically runs every 15 minutes when app is in background
    // On Android, this is managed by WorkManager internally
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15, // 15 minutes
        forceAlarmManager: false, // Use WorkManager if available
        stopOnTerminate: false,
        enableHeadless: true,
        requiredNetworkType: NetworkType.NONE, // Don't require network
      ),
      _handleBackgroundFetch,
      _handleBackgroundTimeout,
    );

    _initialized = true;
  }

  /// Start monitoring background timer
  static Future<void> start() async {
    try {
      final status = await BackgroundFetch.start();
      print('[FocusBackgroundTask] Background fetch started: $status');
    } catch (e) {
      print('[FocusBackgroundTask] Error starting background fetch: $e');
    }
  }

  /// Stop monitoring background timer
  static Future<void> stop() async {
    try {
      await BackgroundFetch.stop();
      print('[FocusBackgroundTask] Background fetch stopped');
    } catch (e) {
      print('[FocusBackgroundTask] Error stopping background fetch: $e');
    }
  }

  /// Main background task handler - called periodically by the system
  static void _handleBackgroundFetch(String taskId) async {
    try {
      print('[FocusBackgroundTask] Background fetch task triggered: $taskId');

      final prefs = await SharedPreferences.getInstance();
      final isRunning = prefs.getBool(_timerIsRunningKey) ?? false;

      if (!isRunning) {
        // Timer not running, nothing to do
        BackgroundFetch.finish(taskId);
        return;
      }

      final targetStr = prefs.getString(_timerTargetKey);
      if (targetStr == null) {
        BackgroundFetch.finish(taskId);
        return;
      }

      final target = DateTime.parse(targetStr);
      final now = DateTime.now();
      final diff = target.difference(now).inSeconds;

      print('[FocusBackgroundTask] Timer target: $target, now: $now, diff: $diff seconds');

      if (diff <= 0) {
        // Timer completed, show notification
        final isBreak = prefs.getBool(_timerIsBreakKey) ?? false;
        await _handleTimerComplete(isBreak);

        // Update preferences for next session
        await _prepareNextSession(isBreak);
      }

      BackgroundFetch.finish(taskId);
    } catch (e) {
      print('[FocusBackgroundTask] Error in background fetch: $e');
      BackgroundFetch.finish(taskId);
    }
  }

  /// Handle background fetch timeout
  static void _handleBackgroundTimeout(String taskId) {
    print('[FocusBackgroundTask] Background fetch timeout: $taskId');
    BackgroundFetch.finish(taskId);
  }

  /// Show notification when timer completes
  static Future<void> _handleTimerComplete(bool isBreak) async {
    try {
      final notificationService = FocusNotificationService();
      await notificationService.init();

      if (isBreak) {
        await notificationService.notifyBreakComplete();
      } else {
        await notificationService.notifyFocusComplete();
      }
    } catch (e) {
      print('[FocusBackgroundTask] Error showing notification: $e');
    }
  }

  /// Prepare next session (switch between focus and break)
  static Future<void> _prepareNextSession(bool wasBreak) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!wasBreak) {
        // Focus finished, prepare break
        const breakMinutes = 5;
        final newTarget = DateTime.now().add(Duration(minutes: breakMinutes));
        await prefs.setString(_timerTargetKey, newTarget.toIso8601String());
        await prefs.setBool(_timerIsBreakKey, true);
      } else {
        // Break finished, prepare next focus
        const focusMinutes = 25;
        final newTarget = DateTime.now().add(Duration(minutes: focusMinutes));
        await prefs.setString(_timerTargetKey, newTarget.toIso8601String());
        await prefs.setBool(_timerIsBreakKey, false);
      }
    } catch (e) {
      print('[FocusBackgroundTask] Error preparing next session: $e');
    }
  }
}
