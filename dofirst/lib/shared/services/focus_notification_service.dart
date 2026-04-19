import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

/// Singleton service for focus session notifications and alert sounds.
class FocusNotificationService {
  static final FocusNotificationService _instance = FocusNotificationService._internal();
  factory FocusNotificationService() => _instance;
  FocusNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _initialized = false;

  /// Initialize the notification plugin. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    // Request notification permission on Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Show a notification popup AND play an alert sound.
  Future<void> notify({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    // Show notification popup
    const androidDetails = AndroidNotificationDetails(
      'focus_session_channel',
      'Focus Session',
      channelDescription: 'Notifications for focus and break session transitions',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
      title,
      body,
      details,
    );

    // Play alert sound using system notification ringtone
    try {
      await _audioPlayer.setSource(AssetSource('sounds/notification.mp3'));
      await _audioPlayer.resume();
    } catch (_) {
      // Fallback: If no custom sound file, the notification itself will still ring
      // via the system default notification sound (playSound: true above)
    }
  }

  /// Notify that a focus session has ended.
  Future<void> notifyFocusComplete() async {
    await notify(
      title: '🎯 Focus Session Complete!',
      body: 'Great work! Time for a 5-minute break.',
    );
  }

  /// Notify that a break session has ended.
  Future<void> notifyBreakComplete() async {
    await notify(
      title: '☕ Break\'s Over!',
      body: 'Let\'s get back to focusing. 25 minutes starts now!',
    );
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
