import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_top_nav_bar.dart';
import '../../../shared/widgets/history_item_card.dart';
import '../../../shared/navigation/no_transition_route.dart';
import '../../home/presentation/home_page.dart';
import '../../tasks/presentation/task_list/task_list_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../history/presentation/history_page.dart';
import 'dashboard_view_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 2) return;
    if (index == 0) pushReplacementNoTransition(context, const HomePage());
    else if (index == 1) pushReplacementNoTransition(context, const TaskListPage());
    else pushReplacementNoTransition(context, const ProfilePage());
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const AppTopNavBar(),
                  Expanded(
                    child: vm.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: () => vm.loadDashboard(),
                            child: CustomScrollView(
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                  sliver: SliverList(
                                    delegate: SliverChildListDelegate([
                                      _buildTitle(),
                                      const SizedBox(height: 24),
                                      _buildSummaryCards(vm),
                                      const SizedBox(height: 24),
                                      _buildTasksDoneCard(vm),
                                      const SizedBox(height: 24),
                                      _buildAverageFocusCard(vm),
                                      const SizedBox(height: 24),
                                      _buildAddTaskButton(context),
                                      const SizedBox(height: 32),
                                      _buildHistoryHeader(context),
                                      const SizedBox(height: 16),
                                      _buildTasksList(vm),
                                      const SizedBox(height: 100), // padding for bottom nav
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
            extendBody: true,
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 2,
              onTap: (index) => _onBottomNavTap(context, index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Your\nDashboard',
      style: TextStyle(
        fontFamily: 'Lexend',
        fontWeight: FontWeight.bold,
        fontSize: 36,
        color: Color(0xFF191C1D),
        height: 1.1,
        letterSpacing: -0.9,
      ),
    );
  }

  Widget _buildSummaryCards(DashboardViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSmallCard(
          title: 'Total Tasks',
          subtitle: 'Active',
          value: '${vm.totalTasks}',
          iconColor: const Color(0xFFEEF2FF),
          iconData: Icons.folder_outlined,
        ),
        _buildSmallCard(
          title: 'High Priority',
          subtitle: 'Needs attention',
          value: '${vm.highPriorityCount}',
          iconColor: const Color(0xFFFFDAD8),
          iconData: Icons.warning_amber_rounded,
        ),
        _buildSmallCard(
          title: 'Completed',
          subtitle: 'Tasks done',
          value: '${vm.completedTasksCount}',
          iconColor: const Color(0xFFF0F0FF),
          iconData: Icons.task_alt,
        ),
      ],
    );
  }

  Widget _buildSmallCard({
    required String title,
    required String subtitle,
    required String value,
    required Color iconColor,
    required IconData iconData,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(iconData, size: 16, color: const Color(0xFF191C1D)),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF191C1D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Color(0xFF191C1D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: Color(0xFF777587),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksDoneCard(DashboardViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ALL',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: const Color(0xFFDAD7FF).withOpacity(0.8),
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    'Tasks Done',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: const Color(0xFFDAD7FF).withOpacity(0.8),
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${vm.completedTasksCount}',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              fontSize: 48,
              color: Color(0xFFDAD7FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageFocusCard(DashboardViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0D000000),
                      offset: Offset(0, 1),
                      blurRadius: 1,
                    )
                  ],
                ),
                child: const Icon(Icons.bar_chart, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AVERAGE FOCUS',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Color(0xFF464555),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        vm.averageFocusFormatted,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Color(0xFF191C1D),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          ' per day',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color: Color(0xFF464555),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(16, 0.2),
              const SizedBox(width: 4),
              _buildBar(24, 0.4),
              const SizedBox(width: 4),
              _buildBar(32, 1.0),
              const SizedBox(width: 4),
              _buildBar(20, 0.6),
              const SizedBox(width: 4),
              _buildBar(28, 0.8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, double opacity) {
    return Container(
      width: 6,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF3525CD).withOpacity(opacity),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3525CD),
        minimumSize: const Size(double.infinity, 49),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
      ),
      onPressed: () {},
      child: const Text(
        '+ Add New Task',
        style: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }


  Widget _buildHistoryHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'History',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF191C1D),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'View All',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF3525CD),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList(DashboardViewModel vm) {
    if (vm.recentHistory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No completed tasks yet.\nFinish a task to see it here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF777587),
            ),
          ),
        ),
      );
    }

    return Column(
      children: vm.recentHistory.map((task) {
        final completedAt = task['completedAt'] as String?;
        String subtitle = '';
        if (completedAt != null) {
          final dt = DateTime.tryParse(completedAt);
          if (dt != null) {
            final local = dt.toLocal();
            final now = DateTime.now();
            final diff = now.difference(local);
            if (diff.inDays == 0) {
              subtitle = 'Today, ${local.hour}:${local.minute.toString().padLeft(2, '0')}';
            } else if (diff.inDays == 1) {
              subtitle = 'Yesterday, ${local.hour}:${local.minute.toString().padLeft(2, '0')}';
            } else {
              subtitle = '${local.day}/${local.month}/${local.year}';
            }
          }
        }
        return HistoryItemCard(
          title: task['title'] as String? ?? 'Untitled',
          subtitle: subtitle,
        );
      }).toList(),
    );
  }
}
