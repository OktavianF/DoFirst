import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:do_not_disturb/do_not_disturb.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_view_model.dart';
import '../../../shared/services/focus_notification_service.dart';

class FocusBreakSettingsPage extends StatefulWidget {
  const FocusBreakSettingsPage({super.key});

  @override
  State<FocusBreakSettingsPage> createState() => _FocusBreakSettingsPageState();
}

class _FocusBreakSettingsPageState extends State<FocusBreakSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Consumer<SettingsViewModel>(
        builder: (context, vm, _) {
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
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Customize your focus sessions and break\nto match your workflow',
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
                                        iconBg: const Color(0xFFF3E5F5),
                                        iconColor: const Color(0xFF3525CD),
                                        title: 'Focus Duration',
                                        subtitle: 'How long you want to focus',
                                        value: '${vm.focusDuration}',
                                        unit: 'min',
                                        onTap: () => _showDurationPicker(
                                          title: 'Focus Duration',
                                          currentValue: vm.focusDuration,
                                          options: [15, 20, 25, 30, 45, 60],
                                          onSelected: (val) => vm.updateFocusDuration(val),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildPickerTile(
                                        icon: Icons.free_breakfast_outlined,
                                        iconBg: const Color(0xFFE8F5E9),
                                        iconColor: const Color(0xFF1B5E20),
                                        title: 'Short Break',
                                        subtitle: 'Take a short break',
                                        value: '${vm.shortBreak}',
                                        unit: 'min',
                                        onTap: () => _showDurationPicker(
                                          title: 'Short Break',
                                          currentValue: vm.shortBreak,
                                          options: [5, 10, 15, 20, 25],
                                          onSelected: (val) => vm.updateShortBreak(val),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildPickerTile(
                                        icon: Icons.coffee_outlined,
                                        iconBg: const Color(0xFFFFF3E0),
                                        iconColor: const Color(0xFFE65100),
                                        title: 'Long Break',
                                        subtitle: 'Take a longer break',
                                        value: '${vm.longBreak}',
                                        unit: 'min',
                                        onTap: () => _showDurationPicker(
                                          title: 'Long Break',
                                          currentValue: vm.longBreak,
                                          options: [15, 20, 25, 30, 45, 60],
                                          onSelected: (val) => vm.updateLongBreak(val),
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
                                    iconBg: const Color(0xFFE8EAF6),
                                    iconColor: const Color(0xFF3525CD),
                                    title: 'Session Before Long Break',
                                    subtitle: 'Number of focus sessions',
                                    value: '${vm.sessionsBeforeLongBreak}',
                                    unit: 'sessions',
                                    onTap: () => _showDurationPicker(
                                      title: 'Sessions Before Long Break',
                                      currentValue: vm.sessionsBeforeLongBreak,
                                      options: [2, 4, 6, 8, 10],
                                      onSelected: (val) => vm.updateSessionsBeforeLongBreak(val),
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
                                        iconBg: const Color(0xFFF3E5F5),
                                        iconColor: const Color(0xFF3525CD),
                                        title: 'Sound',
                                        subtitle: 'Play sound when session ends',
                                        trailingText: vm.sound,
                                        onTap: () => _showSoundPicker(vm),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildToggleTile(
                                        icon: Icons.vibration,
                                        iconBg: const Color(0xFFE3F2FD),
                                        iconColor: const Color(0xFF3525CD),
                                        title: 'Vibration',
                                        subtitle: 'Vibrate when session ends',
                                        value: vm.vibration,
                                        onChanged: (val) => vm.updateVibration(val),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildToggleTile(
                                        icon: Icons.play_circle_outline,
                                        iconBg: const Color(0xFFF3E5F5),
                                        iconColor: const Color(0xFF3525CD),
                                        title: 'Auto Start Next Session',
                                        subtitle: 'Start next focus session automatically',
                                        value: vm.autoStartNextSession,
                                        onChanged: (val) => vm.updateAutoStartNextSession(val),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildToggleTile(
                                        icon: Icons.play_lesson_outlined,
                                        iconBg: const Color(0xFFF3E5F5),
                                        iconColor: const Color(0xFF3525CD),
                                        title: 'Auto Start Break',
                                        subtitle: 'Start break automatically',
                                        value: vm.autoStartBreak,
                                        onChanged: (val) => vm.updateAutoStartBreak(val),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildToggleTile(
                                        icon: Icons.lock_outline,
                                        iconBg: const Color(0xFFFFEBEE),
                                        iconColor: const Color(0xFFD32F2F),
                                        title: 'Focus Lock',
                                        subtitle: 'Lock screen & block notifications',
                                        value: vm.focusLock,
                                        onChanged: (val) => _handleFocusLockToggle(vm, val),
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
                              onPressed: vm.isSaving
                                  ? null
                                  : () async {
                                      final success = await vm.saveSettings();
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Settings saved!')),
                                        );
                                        Navigator.pop(context, true); // Return true to indicate settings changed
                                      } else if (!success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(vm.errorMessage ?? 'Failed to save')),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3525CD),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: vm.isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
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
        },
      ),
    );
  }

  void _handleFocusLockToggle(SettingsViewModel vm, bool value) {
    if (!value) {
      // Turning OFF — no confirmation needed
      vm.updateFocusLock(false);
      return;
    }

    // Turning ON — show confirmation modal
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline, color: Color(0xFFD32F2F), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Aktifkan Focus Lock?',
                  style: TextStyle(
                    color: Color(0xFF191C1D),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ketika Focus Lock aktif dan Pomodoro berjalan:',
                style: TextStyle(
                  color: Color(0xFF464555),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.block, 'Anda tidak bisa keluar dari halaman Focus Session'),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.arrow_back, 'Tombol back & gesture dinonaktifkan'),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.notifications_off, 'Notifikasi dari aplikasi lain akan diblokir (DND)'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3525CD).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3525CD).withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🍅 Teknik Pomodoro',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF3525CD),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Focus ${vm.focusDuration}m → Break ${vm.shortBreak}m → Repeat\n'
                      'Setiap ${vm.sessionsBeforeLongBreak} sesi → Long Break ${vm.longBreak}m',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF464555),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Focus Lock hanya aktif selama timer Pomodoro berjalan. Saat timer di-pause atau dihentikan, lock akan dinonaktifkan.',
                style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E), height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(color: Color(0xFF777587), fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _checkAndRequestDndPermission(vm);
              },
              child: const Text(
                'Ya, Aktifkan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFD32F2F)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF464555), height: 1.3),
          ),
        ),
      ],
    );
  }

  Future<void> _checkAndRequestDndPermission(SettingsViewModel vm) async {
    final dndPlugin = DoNotDisturbPlugin();

    try {
      final hasAccess = await dndPlugin.isNotificationPolicyAccessGranted();
      if (hasAccess) {
        vm.updateFocusLock(true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🔒 Focus Lock diaktifkan!')),
          );
        }
      } else {
        // Guide user to grant DND permission
        if (mounted) {
          final shouldOpen = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text(
                'Izin Diperlukan',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
              ),
              content: const Text(
                'Untuk memblokir notifikasi dari aplikasi lain saat fokus, DoFirst memerlukan izin "Do Not Disturb Access".\n\n'
                'Anda akan diarahkan ke Settings untuk mengaktifkannya. Cukup sekali saja.',
                style: TextStyle(color: Color(0xFF464555), fontSize: 14, height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Nanti', style: TextStyle(color: Color(0xFF777587))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3525CD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Buka Settings'),
                ),
              ],
            ),
          );

          if (shouldOpen == true) {
            await dndPlugin.openNotificationPolicyAccessSettings();
            // After returning from settings, check again
            await Future.delayed(const Duration(seconds: 1));
            final granted = await dndPlugin.isNotificationPolicyAccessGranted();
            if (granted) {
              vm.updateFocusLock(true);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🔒 Focus Lock diaktifkan!')),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Izin belum diberikan. Focus Lock tidak diaktifkan.')),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      // If DND plugin fails (e.g., on iOS), enable lock without DND
      debugPrint('DND plugin error: $e');
      vm.updateFocusLock(true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🔒 Focus Lock diaktifkan (tanpa DND).')),
        );
      }
    }
  }

  void _showDurationPicker({
    required String title,
    required int currentValue,
    required List<int> options,
    required ValueChanged<int> onSelected,
  }) {
    double minVal = 5;
    double maxVal = 90;
    String unitLabel = 'min';

    if (title.toLowerCase().contains('session')) {
      minVal = 1;
      maxVal = 10;
      unitLabel = 'sessions';
    } else if (title.toLowerCase().contains('short')) {
      minVal = 1;
      maxVal = 30;
      unitLabel = 'min';
    } else if (title.toLowerCase().contains('long break')) {
      minVal = 5;
      maxVal = 60;
      unitLabel = 'min';
    }

    int selectedValue = currentValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 12.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adjust $title',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF191C1D),
                            fontFamily: 'Lexend',
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF777587)),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F4F5),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Display Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3525CD).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFF3525CD).withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$selectedValue',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3525CD),
                              fontFamily: 'Lexend',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            unitLabel,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF777587),
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        activeTrackColor: const Color(0xFF3525CD),
                        inactiveTrackColor: const Color(0xFFE8EAF6),
                        thumbColor: const Color(0xFF3525CD),
                        overlayColor: const Color(0xFF3525CD).withValues(alpha: 0.12),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 12,
                          elevation: 4,
                        ),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                      ),
                      child: Slider(
                        value: selectedValue.toDouble().clamp(minVal, maxVal),
                        min: minVal,
                        max: maxVal,
                        divisions: (maxVal - minVal).toInt(),
                        onChanged: (val) {
                          setSheetState(() {
                            selectedValue = val.round();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Presets
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'QUICK PRESETS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF777587),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.start,
                        children: options.map((option) {
                          final isSelected = option == selectedValue;
                          return InkWell(
                            onTap: () {
                              setSheetState(() {
                                selectedValue = option;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF3525CD) : const Color(0xFFF3F4F5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF3525CD) : const Color(0xFFE0E0E0),
                                  width: 1,
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: const Color(0xFF3525CD).withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ] : null,
                              ),
                              child: Text(
                                '$option $unitLabel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : const Color(0xFF191C1D),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          onSelected(selectedValue);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
                        label: const Text(
                          'Confirm Selection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3525CD),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 2,
                          shadowColor: const Color(0xFF3525CD).withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Bug 5: Sound picker bottom sheet with preview
  void _showSoundPicker(SettingsViewModel vm) {
    final sounds = ['Chime', 'Ding', 'Bell', 'Gong', 'Silent'];
    final soundIcons = [
      Icons.music_note,
      Icons.notifications_active,
      Icons.doorbell_outlined,
      Icons.album,
      Icons.volume_off,
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Sound',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a sound for session transitions',
                style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
              ),
              const SizedBox(height: 20),
              ...List.generate(sounds.length, (i) {
                final isSelected = vm.sound.toLowerCase() == sounds[i].toLowerCase();
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3525CD).withValues(alpha: 0.1)
                          : const Color(0xFFF3F4F5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      soundIcons[i],
                      color: isSelected ? const Color(0xFF3525CD) : const Color(0xFF777587),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    sounds[i],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF3525CD) : const Color(0xFF191C1D),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF3525CD), size: 24)
                      : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    vm.updateSound(sounds[i]);
                    // Preview sound
                    _previewSound(sounds[i]);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _previewSound(String soundName) {
    // Use the singleton notification service to preview the sound
    try {
      FocusNotificationService().playSound(soundName.toLowerCase());
    } catch (_) {
      // Ignore preview errors
    }
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
