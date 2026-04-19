import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../home/presentation/home_page.dart';
import '../../../profile/presentation/profile_page.dart';
import '../../../profile/presentation/profile_view_model.dart';
import '../../../../shared/navigation/no_transition_route.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../notifications/presentation/notifications_page.dart';
import '../task_input/task_input_page.dart';
import 'task_list_view_model.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TaskListPageContent();
  }
}

class _TaskListPageContent extends StatefulWidget {
  const _TaskListPageContent();

  @override
  State<_TaskListPageContent> createState() => _TaskListPageContentState();
}

class _TaskListPageContentState extends State<_TaskListPageContent> {
  /// Timer that ticks every minute to update deadline countdowns in realtime
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Refresh UI every 60 seconds so deadline countdowns update in realtime
    _countdownTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TaskListViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopNavigationBar(context),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 24.0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHeaderSection(viewModel),
                        const SizedBox(height: 40.0),
                        _buildHighPrioritySection(viewModel),
                        const SizedBox(height: 40.0),
                        _buildMediumPrioritySection(viewModel),
                        const SizedBox(height: 40.0),
                        _buildLowPrioritySection(viewModel),
                        const SizedBox(
                          height: 120.0,
                        ), // Bottom padding for shell
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TaskInputPage(),
              ),
            );
          },
          backgroundColor: AppColors.primary,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 0) {
      pushReplacementNoTransition(context, const HomePage());
      return;
    }
    if (index == 2) {
      pushReplacementNoTransition(context, const ProfilePage());
    }
  }

  Widget _buildTopNavigationBar(BuildContext context) {
    final profileVm = context.watch<ProfileViewModel>();
    final initial = profileVm.fullName.isNotEmpty
        ? profileVm.fullName[0].toUpperCase()
        : '?';

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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: const Key('task_list_notifications_button'),
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
              const SizedBox(width: 16),
              InkWell(
                key: const Key('task_list_profile_button'),
                onTap: () {
                  pushReplacementNoTransition(context, const ProfilePage());
                },
                customBorder: const CircleBorder(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE2DFFF),
                      width: 4.0,
                    ),
                    color: Colors.grey[300],
                  ),
                  child: ClipOval(
                    child: profileVm.avatarUrl != null
                        ? Image.network(
                            profileVm.avatarUrl!,
                            width: 34,
                            height: 34,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildAvatarFallback(initial),
                          )
                        : _buildAvatarFallback(initial),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String initial) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      color: const Color(0xFFE2DFFF),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F0069),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(TaskListViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Tasks',
          style: TextStyle(
fontWeight: FontWeight.w800,
            fontSize: 36.0,
            color: Color(0xFF191C1D),
            height: 1.1,
            letterSpacing: -0.9,
          ),
        ),
        const SizedBox(height: 16.0),
        TextField(
          onChanged: viewModel.updateSearchQuery,
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 12.0),
              child: Icon(Icons.search, size: 18, color: Color(0xFF777587)),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 46),
            contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
            filled: true,
            fillColor: const Color(0xFFF3F4F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
          style: const TextStyle(
fontSize: 16.0,
            color: Color(0xFF191C1D),
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: viewModel.toggleFilter,
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F5),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.filter_list, size: 18, color: Color(0xFF191C1D)),
                      const SizedBox(width: 8),
                      Text(
                        viewModel.currentFilterLabel,
                        style: const TextStyle(
fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                          color: Color(0xFF191C1D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: InkWell(
                onTap: viewModel.toggleSort,
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F5),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sort, size: 18, color: Color(0xFF191C1D)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          viewModel.currentSortLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                            color: Color(0xFF191C1D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(9999.0),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    letterSpacing: 1.8,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count TASKS',
          style: const TextStyle(
fontWeight: FontWeight.bold,
            fontSize: 12.0,
            color: Color(0xFF777587),
          ),
        ),
      ],
    );
  }

  Widget _buildHighPrioritySection(TaskListViewModel viewModel) {
    final tasks = viewModel.highPriorityTasks;
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'High Priority',
          tasks.length,
          const Color(0xFFBA1A1A),
        ),
        const SizedBox(height: 16.0),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16.0),
          itemBuilder: (context, index) {
            return _buildHighPriorityCard(tasks[index]);
          },
        ),
      ],
    );
  }

  Widget _buildMediumPrioritySection(TaskListViewModel viewModel) {
    final tasks = viewModel.mediumPriorityTasks;
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Medium Priority',
          tasks.length,
          const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 16.0),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12.0),
          itemBuilder: (context, index) {
            return _buildMediumPriorityCard(tasks[index]);
          },
        ),
      ],
    );
  }

  Widget _buildLowPrioritySection(TaskListViewModel viewModel) {
    final tasks = viewModel.lowPriorityTasks;
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Low Priority',
          tasks.length,
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 16.0),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12.0),
          itemBuilder: (context, index) {
            return _buildLowPriorityCard(tasks[index]);
          },
        ),
      ],
    );
  }

  Widget _buildHighPriorityCard(TaskItem task) {
    // Alternate icon logic to match the design (e.g., Task 1 = priority_high, Task 2 = bolt)
    final bool isEmergency = task.title.toLowerCase().contains('emergency') || 
                             task.title.toLowerCase().contains('critical');
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFEDEEEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFBA1A1A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  isEmergency ? Icons.bolt : Icons.priority_high,
                  color: const Color(0xFFBA1A1A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFBA1A1A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'SCORE ${task.score}',
                  style: const TextStyle(
fontWeight: FontWeight.bold,
                    fontSize: 10.0,
                    color: Color(0xFFBA1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            task.title,
            style: const TextStyle(
fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Color(0xFF191C1D),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8.0),
          if (task.description != null) ...[ 
            Text(
              task.description!,
              style: const TextStyle(
fontSize: 12.0,
                color: Color(0xFF777587),
              ),
            ),
            const SizedBox(height: 12.0),
          ],
          if (task.description == null)
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFF777587)),
                const SizedBox(width: 4),
                Text(
                  task.timeText,
                  style: const TextStyle(
fontSize: 12.0,
                    color: Color(0xFF777587),
                  ),
                ),
              ],
            )
          else
            Text(
              task.timeText.toUpperCase(),
              style: const TextStyle(
fontWeight: FontWeight.bold,
                fontSize: 10.0,
                color: Color(0xFFBA1A1A),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediumPriorityCard(TaskItem task) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFEDEEEF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              '${task.score}',
              style: const TextStyle(
fontWeight: FontWeight.bold,
                fontSize: 10.0,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  task.timeText,
                  style: const TextStyle(
fontSize: 12.0,
                    color: Color(0xFF777587),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowPriorityCard(TaskItem task) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFEDEEEF)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Icon(Icons.coffee, size: 18, color: Color(0xFF10B981)),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        task.title,
                        style: const TextStyle(
fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          color: Color(0xFF191C1D),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${task.score}',
                      style: const TextStyle(
fontWeight: FontWeight.bold,
                        fontSize: 10.0,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2.0),
                Text(
                  task.timeText,
                  style: const TextStyle(
fontSize: 12.0,
                    color: Color(0xFF777587),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
