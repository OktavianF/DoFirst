import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../auth/presentation/login/login_view_model.dart';
import '../../auth/presentation/login/login_page.dart';
import '../../home/presentation/home_page.dart';
import '../../home/presentation/home_view_model.dart';
import '../../notifications/presentation/notifications_page.dart';
import '../../tasks/presentation/task_list/task_list_page.dart';
import '../../tasks/presentation/task_list/task_list_view_model.dart';
import '../../../shared/navigation/no_transition_route.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import 'profile_view_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfilePageContent();
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(context),
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProfileCard(vm),
                          const SizedBox(height: 20),
                          // Hide stat dan setting section
                          // _buildStatsSection(vm),
                          // const SizedBox(height: 32),
                          // _buildSettingsList(context),
                          const SizedBox(height: 16),
                          _buildLogoutButton(context),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 0) {
      pushReplacementNoTransition(context, const HomePage());
      return;
    }
    if (index == 1) {
      pushReplacementNoTransition(context, const TaskListPage());
    }
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      height: 57,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 96,
            height: 54,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 54),
          ),
          IconButton(
            key: const Key('profile_notifications_button'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.notifications_none,
              size: 28,
              color: Colors.grey,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ProfileViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1D).withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2DFFF), width: 4),
                ),
                child: ClipOval(
                  child: vm.avatarUrl != null
                      ? Image.network(
                          vm.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.person,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                        )
                      : Container(
                          color: const Color(0xFFE2DFFF),
                          child: Center(
                            child: Text(
                              vm.fullName.isNotEmpty ? vm.fullName[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F0069),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF006C49),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            vm.fullName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            vm.email,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTag(
                label: 'STUDENT',
                background: const Color(0xFFE2DFFF),
                foreground: const Color(0xFF0F0069),
              ),
              const SizedBox(width: 8),
              _buildTag(
                label: 'BETA TESTER',
                background: const Color(0xFFE7E8E9),
                foreground: const Color(0xFF464555),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag({
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildStatsSection(ProfileViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: _ProfileStatCard(
            label: 'TASKS DONE',
            value: '${vm.totalTasks}',
            subtitle: 'tasks',
            icon: Icons.task_alt,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _ProfileStatCard(
            label: 'STREAK',
            value: '-',
            subtitle: 'days',
            icon: Icons.local_fire_department,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _ProfileStatCard(
            label: 'AVG FOCUS',
            value: '-',
            subtitle: '',
            icon: Icons.timer,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    // Keep settings grouped in one card to match the visual hierarchy from Figma.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'SETTINGS & ACCOUNT',
            style: TextStyle(
fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                // First row is a dedicated tile because it contains status + 2-line description.
                _buildGoogleSyncTile(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google Sync setting is being developed'),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSimpleTile(
                  icon: Icons.notifications_none,
                  iconBg: const Color(0xFFFFF7ED),
                  iconColor: const Color(0xFFEA580C),
                  label: 'Notifications',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications setting is being developed'),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSimpleTile(
                  icon: Icons.person_outline,
                  iconBg: const Color(0xFFF1F5F9),
                  iconColor: const Color(0xFF475569),
                  label: 'Account Settings',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account Setting is being developed')),
                    );
                  },
                ),
                _buildDivider(),
                _buildSimpleTile(
                  icon: Icons.help_outline,
                  iconBg: const Color(0xFFECFDF5),
                  iconColor: const Color(0xFF0F766E),
                  label: 'Help & Support',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & Support is being developed')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSyncTile({VoidCallback? onTap}) {
    // Specialized tile used for connected account state and metadata.
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildSquareIcon(
                  icon: Icons.sync,
                  bg: const Color(0xFFEEF2FF),
                  color: const Color(0xFF4F46E5),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Sync',
                      style: TextStyle(
fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Connected to Google\nCalendar',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6CF8BB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Color(0xFF006C49),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Color(0xFF777587),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    VoidCallback? onTap,
  }) {
    // Reusable row for standard one-line settings entries.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildSquareIcon(icon: icon, bg: iconBg, color: iconColor),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF777587)),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareIcon({
    required IconData icon,
    required Color bg,
    required Color color,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _buildDivider() {
    // Subtle separator to keep each settings row visually distinct.
    return Container(height: 1, color: const Color(0x1AC7C4D8));
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Log Out',
                style: TextStyle(
fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Are you sure you want to log out?',
                style: TextStyle(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await AuthRepository().logout();
                    if (context.mounted) {
                      context.read<ProfileViewModel>().clear();
                      context.read<HomeViewModel>().clear();
                      context.read<TaskListViewModel>().clear();
                      
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => LoginViewModel(),
                            child: const LoginPage(),
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBA1A1A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Log Out'),
                ),
              ],
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Text(
          'LOG OUT ACCOUNT',
          style: TextStyle(
fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
            color: Color(0xFFBA1A1A),
          ),
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6CF8BB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
