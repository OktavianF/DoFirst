import 'package:flutter/material.dart';

class FocusBreakSettingsPage extends StatefulWidget {
  const FocusBreakSettingsPage({super.key});

  @override
  State<FocusBreakSettingsPage> createState() => _FocusBreakSettingsPageState();
}

class _FocusBreakSettingsPageState extends State<FocusBreakSettingsPage> {
  int focusDuration = 25;
  int shortBreak = 5;
  int longBreak = 15;
  int sessionsBeforeLongBreak = 4;
  
  bool vibration = true;
  bool autoStartNextSession = true;
  bool autoStartBreak = false;
  String sound = 'Chime';

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
          'Focus & Break Settings',
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
                      'Custumize your focus sessions and break\nto match your workflow',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9E9E9E),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // DURATION SECTION
                    const Text(
                      'DURATION',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191C1D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildPickerTile(
                            icon: Icons.timer_outlined,
                            iconBg: const Color(0xFFF3E5F5), // Light purple
                            iconColor: const Color(0xFF3525CD), // Purple
                            title: 'Focus Duration',
                            subtitle: 'How long you want to focus',
                            value: '$focusDuration',
                            unit: 'min',
                            onTap: () => _showDurationPicker(
                              title: 'Focus Duration',
                              currentValue: focusDuration,
                              options: [15, 20, 25, 30, 45, 60],
                              onSelected: (val) => setState(() => focusDuration = val),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPickerTile(
                            icon: Icons.free_breakfast_outlined,
                            iconBg: const Color(0xFFE8F5E9), // Light green
                            iconColor: const Color(0xFF1B5E20), // Green
                            title: 'Short Break',
                            subtitle: 'Take a short break',
                            value: '$shortBreak',
                            unit: 'min',
                            onTap: () => _showDurationPicker(
                              title: 'Short Break',
                              currentValue: shortBreak,
                              options: [5, 10, 15, 20],
                              onSelected: (val) => setState(() => shortBreak = val),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPickerTile(
                            icon: Icons.coffee_outlined,
                            iconBg: const Color(0xFFFFF3E0), // Light orange
                            iconColor: const Color(0xFFE65100), // Orange
                            title: 'Weekly Team Sync', // Match exactly with screenshot text
                            subtitle: 'Take a longer break',
                            value: '$longBreak',
                            unit: 'min',
                            onTap: () => _showDurationPicker(
                              title: 'Weekly Team Sync',
                              currentValue: longBreak,
                              options: [15, 20, 25, 30, 45, 60],
                              onSelected: (val) => setState(() => longBreak = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // SESSION SECTION
                    const Text(
                      'SESSION',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191C1D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: _buildPickerTile(
                        icon: Icons.autorenew,
                        iconBg: const Color(0xFFE8EAF6), // Light purple background
                        iconColor: const Color(0xFF3525CD), // Purple icon
                        title: 'Session Before Long Break',
                        subtitle: 'Number of focus sessions',
                        value: '$sessionsBeforeLongBreak',
                        unit: 'sessions',
                        onTap: () => _showDurationPicker(
                          title: 'Sessions Before Long Break',
                          currentValue: sessionsBeforeLongBreak,
                          options: [2, 3, 4, 5, 6, 8],
                          onSelected: (val) => setState(() => sessionsBeforeLongBreak = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // OPTIONS SECTION
                    const Text(
                      'OPTIONS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191C1D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildNavigateTile(
                            icon: Icons.notifications_active_outlined,
                            iconBg: const Color(0xFFF3E5F5), // Light purple
                            iconColor: const Color(0xFF3525CD), // Purple
                            title: 'Sound',
                            subtitle: 'Play sound when session ends',
                            trailingText: sound,
                            onTap: () {},
                          ),
                          const SizedBox(height: 24),
                          _buildToggleTile(
                            icon: Icons.vibration,
                            iconBg: const Color(0xFFE3F2FD), // Light blue
                            iconColor: const Color(0xFF3525CD), // Blue-purple
                            title: 'Vibration',
                            subtitle: 'Vibrate when session ends',
                            value: vibration,
                            onChanged: (val) => setState(() => vibration = val),
                          ),
                          const SizedBox(height: 24),
                          _buildToggleTile(
                            icon: Icons.play_circle_outline,
                            iconBg: const Color(0xFFF3E5F5), // Light purple
                            iconColor: const Color(0xFF3525CD), // Purple
                            title: 'Auto Start Next Session',
                            subtitle: 'Start next focus session automatically',
                            value: autoStartNextSession,
                            onChanged: (val) => setState(() => autoStartNextSession = val),
                          ),
                          const SizedBox(height: 24),
                          _buildToggleTile(
                            icon: Icons.play_lesson_outlined, // close icon representation
                            iconBg: const Color(0xFFF3E5F5), // Light purple
                            iconColor: const Color(0xFF3525CD), // Purple
                            title: 'Auto Start Break',
                            subtitle: 'Start break automatically',
                            value: autoStartBreak,
                            onChanged: (val) => setState(() => autoStartBreak = val),
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
                  onPressed: () {
                    // Save action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings Saved')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3525CD), // Deep blue-purple button from screenshot
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
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

  void _showDurationPicker({
    required String title,
    required int currentValue,
    required List<int> options,
    required ValueChanged<int> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set $title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: options.map((option) {
                    final isSelected = option == currentValue;
                    return InkWell(
                      onTap: () {
                        onSelected(option);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF3525CD) : const Color(0xFFF3F4F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$option',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF191C1D),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    required String unit,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Row(
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
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFBDBDBD),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: Color(0xFF9E9E9E),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigateTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Row(
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
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFBDBDBD),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
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
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF191C1D),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFBDBDBD),
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
