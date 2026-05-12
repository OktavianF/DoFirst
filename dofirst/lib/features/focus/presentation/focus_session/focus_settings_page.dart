import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/services/user_preferences_service.dart';
import '../../../../shared/services/custom_audio_service.dart';

class FocusSettingsPage extends StatefulWidget {
  const FocusSettingsPage({super.key});

  @override
  State<FocusSettingsPage> createState() => _FocusSettingsPageState();
}

class _FocusSettingsPageState extends State<FocusSettingsPage> {
  late double focusMinutes;
  late double breakMinutes;
  late double sessionsBeforeLongBreak;
  late bool enableSound;
  late bool enableVibration;
  late bool autoStartNextSession;
  late bool autoStartBreak;
  late String selectedAlarm;
  List<CustomAudioFile> customAudioFiles = [];

  // Available alarm options
  final alarmOptions = [
    {'value': 'alarm', 'label': 'Classic Alarm', 'description': 'Traditional alarm sound'},
    {'value': 'bell', 'label': 'Bell', 'description': 'Gentle bell sound'},
    {'value': 'digital_beep', 'label': 'Digital Beep', 'description': 'Modern beep tone'},
    {'value': 'soft_chime', 'label': 'Soft Chime', 'description': 'Soft melody'},
  ];

  @override
  void initState() {
    super.initState();
    focusMinutes = 25.0;
    breakMinutes = 5.0;
    sessionsBeforeLongBreak = 4.0;
    enableSound = true;
    enableVibration = false;
    autoStartNextSession = false;
    autoStartBreak = false;
    selectedAlarm = 'alarm';
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final focus = await UserPreferencesService.getFocusMinutes() ?? 25;
    final breakDur = await UserPreferencesService.getBreakMinutes() ?? 5;
    final sound = await UserPreferencesService.getEnableSound();
    final vibration = await UserPreferencesService.getEnableVibration();
    final autoNext = await UserPreferencesService.getAutoStartNextSession();
    final autoBreak = await UserPreferencesService.getAutoStartBreak();
    final alarm = await UserPreferencesService.getSelectedAlarm();
    final customFiles = await CustomAudioService.getCustomAudioFiles();

    setState(() {
      focusMinutes = focus.toDouble();
      breakMinutes = breakDur.toDouble();
      enableSound = sound;
      enableVibration = vibration;
      autoStartNextSession = autoNext;
      autoStartBreak = autoBreak;
      selectedAlarm = alarm;
      customAudioFiles = customFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with back button
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF667085)),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Focus & Break Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  'Customize your focus sessions and break to match your workflow',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB8B6C9),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildContentWidgets(),
                  ),
                ),
              ),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4338CA),
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shadowColor: const Color(0x664338CA),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContentWidgets() {
    return [
      // DURATION section
      const Text(
        'DURATION',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),
      ),
      const SizedBox(height: 12),
      _buildDurationCard(
        icon: Icons.timer_outlined,
        iconColor: const Color(0xFF5B5FFF),
        label: 'Focus Duration',
        subtitle: 'How long you want to focus',
        minutes: focusMinutes.round(),
        onMinus: focusMinutes > 5
            ? () => setState(() => focusMinutes = (focusMinutes - 1).clamp(5, 90))
            : null,
        onPlus: focusMinutes < 90
            ? () => setState(() => focusMinutes = (focusMinutes + 1).clamp(5, 90))
            : null,
      ),
      const SizedBox(height: 12),
      _buildDurationCard(
        icon: Icons.coffee_outlined,
        iconColor: const Color(0xFF10B981),
        label: 'Short Break',
        subtitle: 'How long you want to break',
        minutes: breakMinutes.round(),
        onMinus: breakMinutes > 1
            ? () => setState(() => breakMinutes = (breakMinutes - 1).clamp(1, 30))
            : null,
        onPlus: breakMinutes < 30
            ? () => setState(() => breakMinutes = (breakMinutes + 1).clamp(1, 30))
            : null,
      ),
      const SizedBox(height: 12),
      _buildDurationCard(
        icon: Icons.groups_outlined,
        iconColor: const Color(0xFFF59E0B),
        label: 'Weekly Team Sync',
        subtitle: 'Take a longer break',
        minutes: 15,
        onMinus: null,
        onPlus: null,
      ),
      const SizedBox(height: 24),
      // SESSION section
      const Text(
        'SESSION',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),
      ),
      const SizedBox(height: 12),
      _buildSessionCard(),
      const SizedBox(height: 24),
      // OPTIONS section
      const Text(
        'OPTIONS',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),
      ),
      const SizedBox(height: 12),
      _buildOptionCard(
        icon: Icons.volume_up_outlined,
        iconColor: const Color(0xFF5B5FFF),
        label: 'Sound',
        subtitle: 'Play sound when session ends',
        value: enableSound,
        onChanged: (val) => setState(() => enableSound = val),
      ),
      const SizedBox(height: 12),
      // Alarm selector (only show if sound is enabled)
      if (enableSound) ...[
        _buildAlarmSelector(),
        const SizedBox(height: 12),
        _buildCustomAudioUploadSection(),
        const SizedBox(height: 12),
      ],
      _buildOptionCard(
        icon: Icons.vibration,
        iconColor: const Color(0xFF5B5FFF),
        label: 'Vibration',
        subtitle: 'Vibrate when session ends',
        value: enableVibration,
        onChanged: (val) => setState(() => enableVibration = val),
      ),
      const SizedBox(height: 12),
      _buildOptionCard(
        icon: Icons.play_circle_outline,
        iconColor: const Color(0xFF5B5FFF),
        label: 'Auto Start Next Session',
        subtitle: 'Start next focus session automatically',
        value: autoStartNextSession,
        onChanged: (val) => setState(() => autoStartNextSession = val),
      ),
      const SizedBox(height: 12),
      _buildOptionCard(
        icon: Icons.coffee_outlined,
        iconColor: const Color(0xFF5B5FFF),
        label: 'Auto Start Break',
        subtitle: 'Start break automatically',
        value: autoStartBreak,
        onChanged: (val) => setState(() => autoStartBreak = val),
      ),
      const SizedBox(height: 32),
    ];
  }

  Widget _buildDurationCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required int minutes,
    VoidCallback? onMinus,
    VoidCallback? onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1D).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onMinus,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: onMinus != null ? const Color(0xFF5B5FFF) : Colors.grey,
                  size: 24,
                ),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
              Text(
                '$minutes\nmin',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: onPlus,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: onPlus != null ? const Color(0xFF5B5FFF) : Colors.grey,
                  size: 24,
                ),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1D).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B5FFF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.repeat, color: Color(0xFF5B5FFF), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session Before Long Break',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Number of focus sessions',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => setState(() => sessionsBeforeLongBreak =
                    (sessionsBeforeLongBreak - 1).clamp(1, 10)),
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Color(0xFF5B5FFF),
                  size: 24,
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              Text(
                '${sessionsBeforeLongBreak.round()}\nsessions',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => sessionsBeforeLongBreak =
                    (sessionsBeforeLongBreak + 1).clamp(1, 10)),
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF5B5FFF),
                  size: 24,
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1D).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B5FFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.music_note_outlined,
                  color: Color(0xFF5B5FFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alarm Sound',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Select notification sound',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Alarm options as radio buttons
          Column(
            children: alarmOptions.map((option) {
              final value = option['value'] as String;
              final label = option['label'] as String;
              final description = option['description'] as String;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () => setState(() => selectedAlarm = value),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: value,
                        groupValue: selectedAlarm,
                        onChanged: (val) {
                          if (val != null) setState(() => selectedAlarm = val);
                        },
                        activeColor: const Color(0xFF5B5FFF),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAudioUploadSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1D).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B5FFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.upload_file_outlined,
                  color: Color(0xFF5B5FFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Custom Alarm Sound',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Upload your own MP3 or audio file',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleUploadAudio,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B5FFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Upload Audio File'),
            ),
          ),
          // Custom audio files list
          if (customAudioFiles.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            const Text(
              'Your Custom Alarms:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: customAudioFiles.map((audioFile) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () => setState(() => selectedAlarm = audioFile.path),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: audioFile.path,
                          groupValue: selectedAlarm,
                          onChanged: (val) {
                            if (val != null) setState(() => selectedAlarm = val);
                          },
                          activeColor: const Color(0xFF5B5FFF),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                audioFile.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                audioFile.fileName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _handleDeleteAudio(audioFile),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 18,
                          ),
                          constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                          padding: EdgeInsets.zero,
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleUploadAudio() async {
    try {
      final filePath = await CustomAudioService.pickAndSaveAudio('custom_alarm');
      
      if (filePath != null) {
        final customFiles = await CustomAudioService.getCustomAudioFiles();
        setState(() {
          customAudioFiles = customFiles;
          selectedAlarm = filePath;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Audio file uploaded successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error uploading audio: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleDeleteAudio(CustomAudioFile audioFile) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Custom Alarm?'),
        content: Text('Remove "${audioFile.name}" from your custom alarms?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final deleted = await CustomAudioService.deleteCustomAudio(audioFile.path);
      
      if (deleted) {
        final customFiles = await CustomAudioService.getCustomAudioFiles();
        setState(() {
          customAudioFiles = customFiles;
          if (selectedAlarm == audioFile.path) {
            selectedAlarm = 'alarm';
          }
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Audio file deleted')),
          );
        }
      }
    }
  }

  Widget _buildOptionCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1D).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF10B981),
            inactiveThumbColor: const Color(0xFFD0D5DD),
            inactiveTrackColor: const Color(0xFFEAECF0),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    await UserPreferencesService.saveFocusMinutes(focusMinutes.round());
    await UserPreferencesService.saveBreakMinutes(breakMinutes.round());
    await UserPreferencesService.saveEnableSound(enableSound);
    await UserPreferencesService.saveEnableVibration(enableVibration);
    await UserPreferencesService.saveAutoStartNextSession(autoStartNextSession);
    await UserPreferencesService.saveAutoStartBreak(autoStartBreak);
    await UserPreferencesService.saveSelectedAlarm(selectedAlarm);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Focus & Break settings saved')),
      );
    }
  }
}
