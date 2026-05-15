import 'package:flutter/foundation.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../../shared/services/api_client.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepo = SettingsRepository();

  int _focusDuration = 25;
  int _shortBreak = 5;
  int _longBreak = 15;
  int _sessionsBeforeLongBreak = 4;
  bool _vibration = true;
  bool _autoStartNextSession = true;
  bool _autoStartBreak = false;
  String _sound = 'Chime';
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  // Getters
  int get focusDuration => _focusDuration;
  int get shortBreak => _shortBreak;
  int get longBreak => _longBreak;
  int get sessionsBeforeLongBreak => _sessionsBeforeLongBreak;
  bool get vibration => _vibration;
  bool get autoStartNextSession => _autoStartNextSession;
  bool get autoStartBreak => _autoStartBreak;
  String get sound => _sound;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  SettingsViewModel() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _settingsRepo.getSettings();

      _focusDuration = data['focusDuration'] as int? ?? data['focus_duration'] as int? ?? 25;
      _shortBreak = data['shortBreak'] as int? ?? data['short_break'] as int? ?? 5;
      _longBreak = data['longBreak'] as int? ?? data['long_break'] as int? ?? 15;
      _sessionsBeforeLongBreak = data['sessionsBeforeLongBreak'] as int? ?? data['sessions_before_long_break'] as int? ?? 4;
      _vibration = data['vibration'] as bool? ?? true;
      _autoStartNextSession = data['autoStartNextSession'] as bool? ?? data['auto_start_next_session'] as bool? ?? true;
      _autoStartBreak = data['autoStartBreak'] as bool? ?? data['auto_start_break'] as bool? ?? false;
      _sound = data['sound'] as String? ?? 'Chime';
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load settings';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFocusDuration(int value) {
    _focusDuration = value;
    notifyListeners();
  }

  void updateShortBreak(int value) {
    _shortBreak = value;
    notifyListeners();
  }

  void updateLongBreak(int value) {
    _longBreak = value;
    notifyListeners();
  }

  void updateSessionsBeforeLongBreak(int value) {
    _sessionsBeforeLongBreak = value;
    notifyListeners();
  }

  void updateVibration(bool value) {
    _vibration = value;
    notifyListeners();
  }

  void updateAutoStartNextSession(bool value) {
    _autoStartNextSession = value;
    notifyListeners();
  }

  void updateAutoStartBreak(bool value) {
    _autoStartBreak = value;
    notifyListeners();
  }

  void updateSound(String value) {
    _sound = value;
    notifyListeners();
  }

  Future<bool> saveSettings() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _settingsRepo.updateSettings({
        'focusDuration': _focusDuration,
        'shortBreak': _shortBreak,
        'longBreak': _longBreak,
        'sessionsBeforeLongBreak': _sessionsBeforeLongBreak,
        'vibration': _vibration,
        'autoStartNextSession': _autoStartNextSession,
        'autoStartBreak': _autoStartBreak,
        'sound': _sound,
      });
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to save settings';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearState() {
    _focusDuration = 25;
    _shortBreak = 5;
    _longBreak = 15;
    _sessionsBeforeLongBreak = 4;
    _vibration = true;
    _autoStartNextSession = true;
    _autoStartBreak = false;
    _sound = 'Chime';
    _errorMessage = null;
    notifyListeners();
  }
}
