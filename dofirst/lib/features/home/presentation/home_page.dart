import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/navigation/no_transition_route.dart';
import '../../../shared/theme/app_theme.dart';
import '../../profile/presentation/profile_page.dart' show ProfilePage;
import '../../history/presentation/history_page.dart';
import '../../profile/presentation/profile_view_model.dart';
import '../../tasks/presentation/task_list/task_list_page.dart';
import '../../tasks/presentation/task_list/task_list_view_model.dart';
import '../../tasks/presentation/task_input/task_input_page.dart';
import 'package:dofirst/features/focus/presentation/focus_page.dart';
import 'home_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const _HomePageContent();
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  @override
  void initState() {
    super.initState();
    // Ensure dashboard is loaded when page mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final taskVm = context.watch<TaskListViewModel>();
    final historyItems = _buildHistoryItems(vm, taskVm);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Scrollable content
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(
                    top: 65,
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildWelcomeSection(vm),
                      const SizedBox(height: 8),
                      _buildSmallStatsRow(vm),
                      const SizedBox(height: 10),
                      _buildBigCardsRow(vm),
                      const SizedBox(height: 10),
                      _buildAddTaskButton(),
                      const SizedBox(height: 10),
                      _buildHistoryHeader(),
                      const SizedBox(height: 6),
                      ...historyItems.map(_buildHistoryTile),
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          // Fixed header at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 57,
                color: AppColors.background,
                child: _buildTopBar(context),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final profileVm = context.watch<ProfileViewModel>();
    final initial = profileVm.fullName.isNotEmpty
        ? profileVm.fullName[0].toUpperCase()
        : '?';

    return Container(
      height: 57,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/logo.png', width: 80, height: 45, fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 45)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.notifications_none, size: 28, color: Colors.grey),
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage())),
                customBorder: const CircleBorder(),
                child: AppAvatar(
                  source: profileVm.avatarUrl,
                  fallbackText: initial,
                  size: 34,
                  borderWidth: 4,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(HomeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WELCOME TO',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 1.1,
            color: Color(0xFF8A8A9D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Good morning,',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF141420).withValues(alpha: 0.92),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          vm.userName.isNotEmpty ? vm.userName : 'Nadhia',
          style: const TextStyle(
            fontSize: 24,
            height: 1.05,
            fontWeight: FontWeight.w800,
            color: Color(0xFF141420),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF141420),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatsRow(HomeViewModel vm) {
    Widget chip({
      required String label,
      required String value,
      required String caption,
      required Color iconColor,
      required IconData icon,
    }) {
      return Container(
            padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
              borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                  width: 24,
                  height: 24,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
                  child: Icon(icon, size: 14, color: iconColor),
            ),
                const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                    fontSize: 10,
                color: Color(0xFF7E7E8D),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                    fontSize: 20,
                height: 1.0,
                fontWeight: FontWeight.w800,
                color: Color(0xFF141420),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              style: const TextStyle(
                    fontSize: 9,
                color: Color(0xFF9A9AAC),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final highPriorityCount = vm.upcomingTasks
        .where((task) => task.dotColor == const Color(0xFFBA1A1A) || task.dotColor == const Color(0xFFF59E0B))
        .length;

    return Row(
      children: [
        Expanded(
          child: chip(
            label: 'Total Tasks',
            value: vm.totalTasks.toString(),
            caption: 'All tasks',
            iconColor: const Color(0xFF6F63FF),
            icon: Icons.list_alt_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: chip(
            label: 'High Priority',
            value: highPriorityCount.toString(),
            caption: 'Needs attention',
            iconColor: const Color(0xFFFF6B6B),
            icon: Icons.priority_high_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: chip(
            label: 'Completed',
            value: vm.tasksDone.toString(),
            caption: 'Tasks',
            iconColor: const Color(0xFF1FBF75),
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildBigCardsRow(HomeViewModel vm) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 156,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5E4BFF), Color(0xFF4438F3)],
            ),
                borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5E4BFF).withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: const [
                            Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
                            SizedBox(width: 5),
                        Text(
                          'TASKS DONE',
                          style: TextStyle(
                            color: Colors.white,
                                fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                        const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          vm.tasksDone.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                                fontSize: 42,
                            height: 0.95,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                            const SizedBox(width: 8),
                        const Padding(
                              padding: EdgeInsets.only(bottom: 7),
                          child: Text(
                            'this week',
                            style: TextStyle(
                              color: Colors.white70,
                                  fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.78),
                      const Color(0xFF8A6DFF).withValues(alpha: 0.45),
                      const Color(0xFF3B2CE6).withValues(alpha: 0.15),
                    ],
                    stops: const [0.0, 0.58, 1.0],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                        size: 60,
                    color: Color(0xFFEDEBFF),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 96,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'AVERAGE FOCUS',
                        style: TextStyle(
                          color: Color(0xFF7E7E8D),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '3.5h per day',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF141420),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildAddTaskButton() {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF4D37F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextButton.icon(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TaskInputPage())),
        icon: const Icon(Icons.add, size: 18, color: Colors.white),
        label: const Text(
          'Add New Task',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
                fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF141420),
          ),
        ),
        TextButton(
          onPressed: () {
            debugPrint('HomePage: History View All pressed, navigating to HistoryPage');
            pushNoTransition(context, const HistoryPage());
          },
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: const Text(
            'View All',
            style: TextStyle(
              color: Color(0xFF4D37F5),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTile(dynamic task) {
    return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.025), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: task.dotColor.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 15,
              color: task.dotColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF1F1F2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.time,
                  style: const TextStyle(
                    color: Color(0xFF8A8A9D),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFC7C4D8)),
        ],
      ),
    );
  }

  List<UpcomingTask> _buildHistoryItems(HomeViewModel homeVm, TaskListViewModel taskVm) {
    if (taskVm.allTasks.isNotEmpty) {
      return taskVm.allTasks
          .take(4)
          .map(
            (task) => UpcomingTask(
              id: task.id,
              title: task.title,
              deadline: task.deadline,
              dotColor: _priorityColorFromTask(task.priority),
            ),
          )
          .toList();
    }

    return homeVm.upcomingTasks.take(4).toList();
  }

  Color _priorityColorFromTask(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFBA1A1A);
      case 'MEDIUM':
        return const Color(0xFFF59E0B);
      case 'LOW':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF777587);
    }
  }

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 0) return;
    if (index == 1) {
      pushReplacementNoTransition(context, const FocusPage());
      return;
    }
    if (index == 2) {
      pushReplacementNoTransition(context, const TaskListPage());
      return;
    }
    pushReplacementNoTransition(context, const ProfilePage());
  }

}


