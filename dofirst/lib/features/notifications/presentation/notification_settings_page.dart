import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _enableAll = true;
  bool _taskReminders = true;
  bool _focusSessionAlerts = true;
  bool _breakReminders = true;
  bool _streakUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F1F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3525CD)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF191C1D),
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage your notification preferences.\nStay update on what matters to you.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF777587),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Enable Notifications
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enable Notifications',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF191C1D),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Turn on or off all connections',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF777587),
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _enableAll,
                            onChanged: (val) {
                              setState(() {
                                _enableAll = val;
                                _taskReminders = val;
                                _focusSessionAlerts = val;
                                _breakReminders = val;
                                _streakUpdates = val;
                              });
                            },
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFF4F46E5),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFE5E7EB),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'NOTIFICATION PREFERENCE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFF777587),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildTile(
                            iconWidget: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.check_circle_outline,
                                  size: 20, color: Color(0xFF4F46E5)),
                            ),
                            title: 'Task Reminders',
                            subtitle: 'Get reminded about upcoming\nor pending tasks',
                            value: _taskReminders,
                            onChanged: _enableAll
                                ? (val) => setState(() => _taskReminders = val)
                                : null,
                            isFirst: true,
                          ),
                          _buildDivider(),
                          _buildTile(
                            iconWidget: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.timer_outlined,
                                  size: 20, color: Color(0xFF059669)),
                            ),
                            title: 'Focus Session Alerts',
                            subtitle: 'Notifications when your focus\nsession ends',
                            value: _focusSessionAlerts,
                            onChanged: _enableAll
                                ? (val) => setState(() => _focusSessionAlerts = val)
                                : null,
                          ),
                          _buildDivider(),
                          _buildTile(
                            iconWidget: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.coffee_outlined,
                                  size: 20, color: Color(0xFFEA580C)),
                            ),
                            title: 'Break Reminders',
                            subtitle: 'Gentle reminders to take\na break',
                            value: _breakReminders,
                            onChanged: _enableAll
                                ? (val) => setState(() => _breakReminders = val)
                                : null,
                          ),
                          _buildDivider(),
                          _buildTile(
                            iconWidget: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.local_fire_department_outlined,
                                  size: 20, color: Color(0xFFE11D48)),
                            ),
                            title: 'Streak Updates',
                            subtitle: 'Celebrate your streak milestones',
                            value: _streakUpdates,
                            onChanged: _enableAll
                                ? (val) => setState(() => _streakUpdates = val)
                                : null,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Save Preferences button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3525CD), Color(0xFF4F46E5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                      offset: const Offset(0, 6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification preferences saved!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 17),
                      child: Center(
                        child: Text(
                          'Save Preferences',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  Widget _buildTile({
    required Widget iconWidget,
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      onTap: onChanged != null ? () => onChanged(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF191C1D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF777587),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF4F46E5),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFE5E7EB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: const Color(0xFFF0F1F8));
  }
}