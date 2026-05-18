import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/repositories/settings_repository.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends State<NotificationPreferencesPage> {
  bool enableNotifications = false;
  bool taskReminders = false;
  bool focusSessionAlerts = false;
  bool breakReminders = false;
  bool streakUpdates = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // 1. Load local SharedPreferences first (for instant display)
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      enableNotifications = prefs.getBool('enable_notifications') ?? false;
      taskReminders = prefs.getBool('task_reminders') ?? false;
      focusSessionAlerts = prefs.getBool('focus_session_alerts') ?? false;
      breakReminders = prefs.getBool('break_reminders') ?? false;
      streakUpdates = prefs.getBool('streak_updates') ?? false;
    });

    // 2. Load from database in background to sync
    try {
      final dbSettings = await SettingsRepository().getSettings();
      final dbTaskReminders = dbSettings['taskReminders'] as bool?;
      if (dbTaskReminders != null) {
        setState(() {
          taskReminders = dbTaskReminders;
        });
        await prefs.setBool('task_reminders', dbTaskReminders);
      }
    } catch (e) {
      debugPrint('Failed to load database settings: $e');
    }
  }

  Future<void> _savePreferences() async {
    // 1. Save locally first
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_notifications', enableNotifications);
    await prefs.setBool('task_reminders', taskReminders);
    await prefs.setBool('focus_session_alerts', focusSessionAlerts);
    await prefs.setBool('break_reminders', breakReminders);
    await prefs.setBool('streak_updates', streakUpdates);

    // 2. Sync to database
    try {
      await SettingsRepository().updateSettings({
        'taskReminders': taskReminders,
      });
    } catch (e) {
      debugPrint('Failed to sync settings to database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF777587)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF191C1D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage your notification preferences.\nStay update on what matters to you.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9E9E9E), // Light grey text as per design
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Main Enable Notifications toggle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Enable Notifications',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF191C1D),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Turn on or off all connections',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFBDBDBD), // light grey subtitle
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: enableNotifications,
                            onChanged: (val) {
                              setState(() {
                                enableNotifications = val;
                                if (!val) {
                                  taskReminders = false;
                                  focusSessionAlerts = false;
                                  breakReminders = false;
                                  streakUpdates = false;
                                }
                              });
                            },
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFF6CF8BB), // Match the bright green from the screenshot
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
                      child: Text(
                        'NOTIFICATION PREFERENCE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ),
                    
                    // Options List
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildPreferenceItem(
                            icon: Icons.check_circle_outline,
                            iconBg: const Color(0xFFF3E5F5), // Light purple
                            iconColor: const Color(0xFF4A148C), // Purple
                            title: 'Task Reminders',
                            subtitle: 'Get reminded about upcoming\nor pending tasks',
                            value: taskReminders,
                            onChanged: enableNotifications ? (val) {
                              setState(() => taskReminders = val);
                            } : null,
                          ),
                          const SizedBox(height: 24),
                          _buildPreferenceItem(
                            icon: Icons.timer_outlined,
                            iconBg: const Color(0xFFE8F5E9), // Light green
                            iconColor: const Color(0xFF1B5E20), // Dark green
                            title: 'Focus Session Alerts',
                            subtitle: 'Notifications when your focus\nsession ends',
                            value: focusSessionAlerts,
                            onChanged: enableNotifications ? (val) {
                              setState(() => focusSessionAlerts = val);
                            } : null,
                          ),
                          const SizedBox(height: 24),
                          _buildPreferenceItem(
                            icon: Icons.free_breakfast_outlined,
                            iconBg: const Color(0xFFFFF3E0), // Light orange
                            iconColor: const Color(0xFFE65100), // Dark orange
                            title: 'Break Reminders',
                            subtitle: 'Gentle reminders to take\na break',
                            value: breakReminders,
                            onChanged: enableNotifications ? (val) {
                              setState(() => breakReminders = val);
                            } : null,
                          ),
                          const SizedBox(height: 24),
                          _buildPreferenceItem(
                            icon: Icons.local_fire_department_outlined,
                            iconBg: const Color(0xFFFFEBEE), // Light red
                            iconColor: const Color(0xFFB71C1C), // Dark red
                            title: 'Streak Updates',
                            subtitle: 'Celebrate your streak milestones',
                            value: streakUpdates,
                            onChanged: enableNotifications ? (val) {
                              setState(() => streakUpdates = val);
                            } : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Save Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _savePreferences();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preferences Saved')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F37C9), // Deep blue-purple button from screenshot
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 10,
                    shadowColor: const Color(0xFF3F37C9).withValues(alpha: 0.3),
                  ),
                  child: const Text(
                    'Save Preferences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF191C1D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFBDBDBD),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFF6CF8BB),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFE0E0E0),
        ),
      ],
    );
  }
}
