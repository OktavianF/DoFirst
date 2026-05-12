import 'package:dofirst/features/focus/presentation/focus_page.dart';
import 'package:dofirst/features/home/presentation/home_page.dart';
import 'package:dofirst/features/home/presentation/home_view_model.dart';
import 'package:dofirst/features/profile/presentation/profile_page.dart' show ProfilePage;
import 'package:dofirst/features/profile/presentation/profile_view_model.dart';
import 'package:dofirst/features/tasks/presentation/task_list/task_list_page.dart';
import 'package:dofirst/features/tasks/presentation/task_list/task_list_view_model.dart';
import 'package:dofirst/shared/navigation/no_transition_route.dart';
import 'package:dofirst/shared/widgets/app_avatar.dart';
import 'package:dofirst/shared/widgets/app_bottom_nav_bar.dart';
import 'package:dofirst/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HistoryPageContent();
  }
}

class _HistoryPageContent extends StatelessWidget {
  const _HistoryPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final taskViewModel = context.watch<TaskListViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFF0F4FF),
              Color(0xFFF8F9FA),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopNavigationBar(context, viewModel),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildHistoryTitle(),
                          const SizedBox(height: 16.0),
                          _buildHistoryList(viewModel, taskViewModel),
                          const SizedBox(height: 32.0),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: -1, // No active tab for history
        onTap: (index) => _onBottomNavTap(context, viewModel, index),
      ),
    );
  }

  void _onBottomNavTap(
    BuildContext context,
    HomeViewModel viewModel,
    int index,
  ) {
    if (index == 0) {
      pushReplacementNoTransition(context, HomePage());
      return;
    } else if (index == 1) {
      pushReplacementNoTransition(context, FocusPage());
      return;
    } else if (index == 2) {
      pushReplacementNoTransition(context, TaskListPage());
      return;
    } else if (index == 3) {
      pushReplacementNoTransition(context, ProfilePage());
      return;
    }
  }

  Widget _buildTopNavigationBar(
    BuildContext context,
    HomeViewModel viewModel,
  ) {
    // Read profile data from ProfileViewModel to show avatar
    final profileVm = context.watch<ProfileViewModel>();

    String initials = 'U';
    if (profileVm.fullName.isNotEmpty) {
      final parts = profileVm.fullName.split(' ');
      initials = parts.map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
    }

    final avatarChild = AppAvatar(
      source: profileVm.avatarUrl,
      fallbackText: initials,
      size: 36,
      borderWidth: 0,
      borderColor: Colors.transparent,
      fallbackBackgroundColor: const Color(0xFFF3F4F5),
    );

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button on the left
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF667085)),
          ),
          GestureDetector(
            onTap: () => _onBottomNavTap(context, viewModel, 3),
            child: avatarChild,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTitle() {
    return const Text(
      'History',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 28.0,
        color: Color(0xFF191C1D),
      ),
    );
  }

  Widget _buildHistoryList(HomeViewModel homeViewModel, TaskListViewModel taskViewModel) {
    final taskItems = taskViewModel.allTasks
        .map(
          (task) => HistoryItem(
            title: task.title,
            time: task.timeText,
            iconColor: _priorityColor(task.priority),
          ),
        )
        .toList();

    final fallbackItems = homeViewModel.upcomingTasks
        .map(
          (task) => HistoryItem(
            title: task.title,
            time: task.time,
            iconColor: task.dotColor,
          ),
        )
        .toList();

    final historyItems = taskItems.isNotEmpty ? taskItems : fallbackItems;

    if (historyItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Text(
          'No tasks yet',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF777587),
          ),
        ),
      );
    }

    return Column(
      children: historyItems.map(_buildHistoryItem).toList(),
    );
  }

  Widget _buildHistoryItem(HistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          // Green checkmark icon
          Icon(
            Icons.check_circle,
            size: 24,
            color: item.iconColor,
          ),
          const SizedBox(width: 16.0),
          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0,
                    color: Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12.0,
                    color: Color(0xFF777587),
                  ),
                ),
              ],
            ),
          ),
          // Chevron icon
          const Icon(
            Icons.chevron_right,
            color: Color(0xFFC7C4D8),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFBA1A1A);
      case 'MEDIUM':
        return const Color(0xFFF59E0B);
      case 'LOW':
        return const Color(0xFF1ABC9C);
      default:
        return const Color(0xFF777587);
    }
  }
}

class HistoryItem {
  final String title;
  final String time;
  final Color iconColor;

  HistoryItem({
    required this.title,
    required this.time,
    required this.iconColor,
  });
}
