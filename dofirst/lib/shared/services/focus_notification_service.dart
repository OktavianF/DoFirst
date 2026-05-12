import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'user_preferences_service.dart';

/// Singleton service for focus session notifications and alert sounds.
class FocusNotificationService {
  static final FocusNotificationService _instance = FocusNotificationService._internal();
  factory FocusNotificationService() => _instance;
  FocusNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _initialized = false;
  Timer? _alarmLoopTimer;
  bool _isAlarmPlaying = false;

  /// Initialize the notification plugin. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _notifications.initialize(initSettings);

      // Request notification permission on Android 13+
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _initialized = true;
    } catch (_) {
      // In widget tests / unsupported platforms, notification plugin may be absent.
      _initialized = false;
    }
  }

  /// Play alarm sound repeatedly for a specified duration
  /// soundAsset can be either:
  /// - Asset path: 'sounds/alarm.wav'
  /// - File path: '/data/user/0/com.example.app/documents/custom_alarms/MySound.mp3'
  Future<void> playAlarmSound({
    String soundAsset = 'sounds/alarm.wav',
    Duration duration = const Duration(seconds: 10),
  }) async {
    final soundEnabled = await UserPreferencesService.getEnableSound();
    if (soundEnabled == false) return;

    try {
      _isAlarmPlaying = true;
      
      // Cancel any existing alarm loop
      _alarmLoopTimer?.cancel();

      // Try to play alarm sound (asset or file)
      try {
        // Detect if it's a file path or asset path
        if (soundAsset.startsWith('sounds/')) {
          // Asset file
          await _audioPlayer.setSource(AssetSource(soundAsset));
        } else {
          // File path - load from device storage using file URI
          final fileUri = 'file://$soundAsset';
          await _audioPlayer.setSourceUrl(fileUri);
        }
        
        await _audioPlayer.setVolume(1.0); // Max volume
        await _audioPlayer.setPlaybackRate(1.0);
        await _audioPlayer.resume();
      } catch (_) {
        // If custom sound fails, try system alert sound instead
        await SystemSound.play(SystemSoundType.alert);
      }

      // Loop alarm sound by restarting it every 2 seconds
      // This ensures continuous alarm even if audio file is shorter
      _alarmLoopTimer = Timer.periodic(const Duration(milliseconds: 2000), (timer) async {
        if (!_isAlarmPlaying) {
          timer.cancel();
          return;
        }
        try {
          // Simply restart playback every 2 seconds to ensure continuous alarm
          await _audioPlayer.resume();
        } catch (_) {
          // Ignore playback errors
        }
      });

      // Stop alarm after specified duration
      Future.delayed(duration, () {
        stopAlarmSound();
      });
    } catch (_) {
      _isAlarmPlaying = false;
    }
  }

  /// Stop alarm sound immediately
  Future<void> stopAlarmSound() async {
    try {
      _isAlarmPlaying = false;
      _alarmLoopTimer?.cancel();
      _alarmLoopTimer = null;
      await _audioPlayer.stop();
    } catch (_) {
      // Ignore stop errors
    }
  }

  /// Play vibration pattern if enabled
  Future<void> playVibration({int count = 3}) async {
    final vibrationEnabled = await UserPreferencesService.getEnableVibration();
    if (vibrationEnabled == false) return;

    try {
      for (int i = 0; i < count; i++) {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (_) {
      // Ignore if haptic feedback not supported
    }
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

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
        title,
        body,
        details,
      );
    } catch (_) {
      // Ignore when platform notifications are unavailable.
    }

    // Play alarm sound
    try {
      final selectedAlarm = await UserPreferencesService.getSelectedAlarm();
      String soundAsset;
      
      // Check if it's a custom file path or predefined alarm name
      if (selectedAlarm.startsWith('/') || selectedAlarm.contains('documents')) {
        // Custom file path
        soundAsset = selectedAlarm;
      } else {
        // Predefined alarm from assets
        soundAsset = 'sounds/$selectedAlarm.wav';
      }
      
      // Validate file exists before playing
      if (!soundAsset.startsWith('sounds/')) {
        final file = File(soundAsset);
        if (!await file.exists()) {
          // File doesn't exist, fall back to default
          soundAsset = 'sounds/alarm.wav';
        }
      }
      
      await playAlarmSound(
        soundAsset: soundAsset,
        duration: const Duration(seconds: 15),
      );
    } catch (_) {
      // Fallback to system alert if custom sound fails
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {
        // Ignore if system sound fails
      }
    }

    // Play vibration pattern
    await playVibration(count: 3);
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

  Future<void> dispose() async {
    await stopAlarmSound();
    _audioPlayer.dispose();
  }
}
