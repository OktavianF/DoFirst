import 'dart:async';
import 'package:dofirst/features/focus/presentation/focus_session/focus_session_page.dart';
import 'package:dofirst/features/profile/presentation/profile_page.dart';
import 'package:dofirst/features/profile/presentation/profile_view_model.dart';
import 'package:dofirst/features/tasks/presentation/task_list/task_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/navigation/no_transition_route.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../notifications/presentation/notifications_page.dart';
import 'home_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomePageContent();
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  /// Timer that ticks every minute to update deadline countdowns in realtime
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) {
        context.read<HomeViewModel>().refreshCountdowns();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

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
                      vertical: 16.0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // _buildHeaderSection(viewModel),
                        // const SizedBox(height: 32.0),
                        _buildHeroTaskSection(context, viewModel),
                        const SizedBox(height: 32.0),
                        _buildUpNextSection(context, viewModel),
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
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
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
      return;
    } else if (index == 1) {
      pushReplacementNoTransition(context, const TaskListPage());
    } else {
      pushReplacementNoTransition(context, const ProfilePage());
    }
  }

  void _openFocusSession(BuildContext context, String taskName, String? taskId) {
    pushNoTransition(context, FocusSessionPage(taskName: taskName, taskId: taskId));
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
                key: const Key('home_notifications_button'),
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
                key: const Key('home_profile_button'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
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

  Widget _buildHeaderSection(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME BACK',
          style: TextStyle(
fontWeight: FontWeight.w400,
            fontSize: 12.0,
            letterSpacing: 2.4,
            color: const Color(0xFF777587),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Good morning,\n${viewModel.userName}',
          style: const TextStyle(
fontWeight: FontWeight.bold,
            fontSize: 36.0,
            color: Color(0xFF191C1D),
            height: 1.1,
            letterSpacing: -0.9,
          ),
        ),
        const SizedBox(height: 16.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F5),
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TASKS DONE',
                      style: TextStyle(
fontWeight: FontWeight.bold,
                        fontSize: 10.0,
                        letterSpacing: 1.0,
                        color: const Color(0xFF777587),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${viewModel.tasksDone} ',
                          style: const TextStyle(
fontWeight: FontWeight.w800,
                            fontSize: 24.0,
                            color: Color(0xFF191C1D),
                          ),
                        ),
                        Text(
                          '/ ${viewModel.totalTasks}',
                          style: TextStyle(
fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                            color: const Color(0xFF777587),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroTaskSection(BuildContext context, HomeViewModel viewModel) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10.0),
          padding: const EdgeInsets.all(33.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32.0),
            border: Border.all(
              color: const Color(0xFFC7C4D8).withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF191C1D).withValues(alpha: 0.06),
                offset: const Offset(0, 20),
                blurRadius: 40.0,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewModel.heroTaskTitle,
                          style: const TextStyle(
fontWeight: FontWeight.bold,
                            fontSize: 30.0,
                            color: Color(0xFF191C1D),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 16,
                              color: Color(0xFF464555),
                            ),
                            const SizedBox(width: 6.0),
                            Flexible(
                              child: Text(
                                viewModel.heroTaskTime,
                                style: const TextStyle(
fontWeight: FontWeight.normal,
                                  fontSize: 16.0,
                                  color: Color(0xFF464555),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        viewModel.heroTaskScore.toString(),
                        style: const TextStyle(
fontWeight: FontWeight.w800,
                          fontSize: 36.0,
                          letterSpacing: -1.8,
                          color: Color(0xFF3525CD),
                        ),
                      ),
                      Text(
                        'SCORE',
                        style: TextStyle(
fontWeight: FontWeight.bold,
                          fontSize: 10.0,
                          letterSpacing: 1.0,
                          color: const Color(0xFF777587),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: viewModel.heroTaskTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7E8E9),
                      borderRadius: BorderRadius.circular(9999.0),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: const TextStyle(
fontWeight: FontWeight.bold,
                        fontSize: 10.0,
                        letterSpacing: 0.5,
                        color: Color(0xFF464555),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24.0),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3525CD), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3525CD).withValues(alpha: 0.2),
                      offset: const Offset(0, 20),
                      blurRadius: 25.0,
                      spreadRadius: -5.0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const Key('start_now_button'),
                    borderRadius: BorderRadius.circular(24.0),
                    onTap: () =>
                        _openFocusSession(context, viewModel.heroTaskTitle, viewModel.heroTaskId),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Start Now',
                            style: TextStyle(
fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -2.0,
          left: 24.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFAB373B),
              borderRadius: BorderRadius.circular(9999.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 10),
                  blurRadius: 15.0,
                  spreadRadius: -3.0,
                ),
              ],
            ),
            child: const Text(
              'HIGHEST PRIORITY',
              style: TextStyle(
fontWeight: FontWeight.bold,
                fontSize: 10.0,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpNextSection(BuildContext context, HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Up Next',
                style: TextStyle(
fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Color(0xFF191C1D),
                ),
              ),
              TextButton(
                key: const Key('view_all_tasks_button'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TaskListPage()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
fontWeight: FontWeight.w600,
                    fontSize: 14.0,
                    color: const Color(0xFF3525CD),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        Column(
          children: viewModel.upcomingTasks.map((task) {
            return InkWell(
              onTap: () => _openFocusSession(context, task.title, task.id),
              borderRadius: BorderRadius.circular(24.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F5),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: task.dotColor,
                        shape: BoxShape.circle,
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
fontWeight: FontWeight.w600,
                              fontSize: 14.0,
                              color: Color(0xFF191C1D),
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            task.time,
                            style: TextStyle(
fontWeight: FontWeight.normal,
                              fontSize: 12.0,
                              color: const Color(0xFF777587),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFFC7C4D8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
