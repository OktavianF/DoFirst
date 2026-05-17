import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service for focus session notifications and alert sounds.
class FocusNotificationService {
  static final FocusNotificationService _instance = FocusNotificationService._internal();
  factory FocusNotificationService() => _instance;
  FocusNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _initialized = false;

  /// Available sound options
  static const List<String> availableSounds = ['Chime', 'Ding', 'Bell', 'Gong', 'Silent'];

  /// Map sound name to asset file
  static const Map<String, String> _soundFiles = {
    'chime': 'sounds/chime.mp3',
    'ding': 'sounds/ding.mp3',
    'bell': 'sounds/bell.mp3',
    'gong': 'sounds/gong.mp3',
    'silent': '', // No sound
  };

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

  /// Get the user's preferred sound from SharedPreferences
  Future<String> _getSoundPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_settings_sound');
      return cached ?? 'chime';
    } catch (_) {
      return 'chime';
    }
  }

  /// Save sound preference locally for quick access
  Future<void> saveSoundPreference(String soundName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_settings_sound', soundName.toLowerCase());
  }

  /// Play a specific sound by name
  Future<void> playSound(String soundName) async {
    final key = soundName.toLowerCase();
    if (key == 'silent') return;

    final assetPath = _soundFiles[key];
    if (assetPath == null || assetPath.isEmpty) return;

    try {
      print('DEBUG: playSound playing asset: $assetPath');
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e, stack) {
      print('DEBUG: playSound failed with error: $e');
      print(stack);
    }
  }

  /// Show a notification popup AND play the user's preferred alert sound.
  Future<void> notify({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    // Show notification popup
    const androidDetails = AndroidNotificationDetails(
      'focus_session_channel_silent',
      'Focus Session Alerts',
      channelDescription: 'Notifications for focus and break session transitions without default system beep',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
      title,
      body,
      details,
    );

    // Play user's preferred sound
    final soundPref = await _getSoundPreference();
    await playSound(soundPref);
  }

  /// Notify that a focus session has ended.
  Future<void> notifyFocusComplete() async {
    await notify(
      title: '🎯 Focus Session Complete!',
      body: 'Great work! Time for a break.',
    );
  }

  /// Notify that a break session has ended.
  Future<void> notifyBreakComplete() async {
    await notify(
      title: '☕ Break\'s Over!',
      body: 'Let\'s get back to focusing!',
    );
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
