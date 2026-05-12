import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _profileDisplayNameKey = 'profile_display_name_override';
  static const String _profileAvatarUrlKey = 'profile_avatar_url_override';
  static const String _focusMinutesKey = 'focus_session_focus_minutes';
  static const String _breakMinutesKey = 'focus_session_break_minutes';
  static const String _enableSoundKey = 'focus_session_enable_sound';
  static const String _enableVibrationKey = 'focus_session_enable_vibration';
  static const String _autoStartNextSessionKey = 'focus_session_auto_start_next';
  static const String _autoStartBreakKey = 'focus_session_auto_start_break';
  static const String _selectedAlarmKey = 'focus_session_selected_alarm';

  static Future<String?> getProfileDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileDisplayNameKey);
  }

  static Future<String?> getProfileAvatarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileAvatarUrlKey);
  }

  static Future<void> saveProfileDisplayName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value.trim().isEmpty) {
      await prefs.remove(_profileDisplayNameKey);
      return;
    }
    await prefs.setString(_profileDisplayNameKey, value.trim());
  }

  static Future<void> saveProfileAvatarUrl(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      await prefs.remove(_profileAvatarUrlKey);
      return;
    }
    await prefs.setString(_profileAvatarUrlKey, normalized);
  }

  static Future<int?> getFocusMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_focusMinutesKey);
  }

  static Future<int?> getBreakMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_breakMinutesKey);
  }

  static Future<void> saveFocusMinutes(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_focusMinutesKey, value);
  }

  static Future<void> saveBreakMinutes(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_breakMinutesKey, value);
  }

  static Future<bool> getEnableSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enableSoundKey) ?? true;
  }

  static Future<void> saveEnableSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enableSoundKey, value);
  }

  static Future<bool> getEnableVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enableVibrationKey) ?? true;
  }

  static Future<void> saveEnableVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enableVibrationKey, value);
  }

  static Future<bool> getAutoStartNextSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoStartNextSessionKey) ?? true;
  }

  static Future<void> saveAutoStartNextSession(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoStartNextSessionKey, value);
  }

  static Future<bool> getAutoStartBreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoStartBreakKey) ?? false;
  }

  static Future<void> saveAutoStartBreak(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoStartBreakKey, value);
  }

  /// Get selected alarm sound type (default: 'alarm')
  static Future<String> getSelectedAlarm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedAlarmKey) ?? 'alarm';
  }

  /// Save selected alarm sound type
  static Future<void> saveSelectedAlarm(String alarmType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedAlarmKey, alarmType);
  }

  static Future<void> clearProfileOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileDisplayNameKey);
    await prefs.remove(_profileAvatarUrlKey);
  }
}