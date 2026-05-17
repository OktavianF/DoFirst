import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_top_nav_bar.dart';
import '../../../shared/widgets/history_item_card.dart';
import '../../../shared/navigation/no_transition_route.dart';
import '../../home/presentation/home_page.dart';
import '../../tasks/presentation/task_list/task_list_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../history/presentation/history_page.dart';
import '../../tasks/presentation/task_input/task_input_page.dart';
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
                                      _buildTasksList(context, vm),
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
    return Text(
      'Your\nDashboard',
      style: TextStyle(
        fontFamily: GoogleFonts.lexend().fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 36,
        color: const Color(0xFF191C1D),
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
              style: TextStyle(
                fontFamily: GoogleFonts.lexend().fontFamily,
                fontSize: 12,
                color: const Color(0xFF191C1D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: GoogleFonts.lexend().fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: const Color(0xFF191C1D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: GoogleFonts.lexend().fontFamily,
                fontSize: 10,
                color: const Color(0xFF777587),
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
                      fontFamily: GoogleFonts.lexend().fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: const Color(0xFFDAD7FF).withOpacity(0.8),
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    'Tasks Done',
                    style: TextStyle(
                      fontFamily: GoogleFonts.lexend().fontFamily,
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
            style: TextStyle(
              fontFamily: GoogleFonts.lexend().fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 48,
              color: const Color(0xFFDAD7FF),
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
                  Text(
                    'AVERAGE FOCUS',
                    style: TextStyle(
                      fontFamily: GoogleFonts.lexend().fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: const Color(0xFF464555),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        vm.averageFocusFormatted,
                        style: TextStyle(
                          fontFamily: GoogleFonts.lexend().fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: const Color(0xFF191C1D),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          ' per day',
                          style: TextStyle(
                            fontFamily: GoogleFonts.lexend().fontFamily,
                            fontSize: 14,
                            color: const Color(0xFF464555),
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
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskInputPage()),
        );
      },
      child: Text(
        '+ Add New Task',
        style: TextStyle(
          fontFamily: GoogleFonts.lexend().fontFamily,
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
        Text(
          'History',
          style: TextStyle(
            fontFamily: GoogleFonts.lexend().fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: const Color(0xFF191C1D),
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
          child: Text(
            'View All',
            style: TextStyle(
              fontFamily: GoogleFonts.lexend().fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: const Color(0xFF3525CD),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList(BuildContext context, DashboardViewModel vm) {
    if (vm.recentHistory.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No completed tasks yet.\nFinish a task to see it here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: GoogleFonts.lexend().fontFamily,
              fontSize: 14,
              color: const Color(0xFF777587),
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
          onTap: () => _showCompletedTaskDetail(context, task),
        );
      }).toList(),
    );
  }

  static void _showCompletedTaskDetail(BuildContext context, Map<String, dynamic> task) {
    final title = task['title'] as String? ?? 'Untitled';
    final description = task['description'] as String?;
    final completedAt = task['completedAt'] as String?;
    final score = (task['score'] as num?)?.toStringAsFixed(1) ?? '-';
    final importance = task['importance'] as int?;
    final difficulty = task['difficulty'] as int?;
    final urgency = task['urgency'] as int?;

    String completedDate = '';
    if (completedAt != null) {
      final dt = DateTime.tryParse(completedAt);
      if (dt != null) {
        final local = dt.toLocal();
        final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        completedDate = '${months[local.month - 1]} ${local.day}, ${local.year} at ${local.hour}:${local.minute.toString().padLeft(2, '0')}';
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE2F5EA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, color: Color(0xFF1E6C45), size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191C1D),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3525CD).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Score $score',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3525CD),
                      ),
                    ),
                  ),
                ],
              ),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF777587), height: 1.5),
                ),
              ],
              const SizedBox(height: 20),
              if (completedDate.isNotEmpty)
                _detailRow(Icons.event_available, 'Completed', completedDate),
              if (importance != null)
                _detailRow(Icons.star_outline, 'Importance', 'Level $importance'),
              if (difficulty != null)
                _detailRow(Icons.fitness_center, 'Difficulty', ['Easy','Medium','Hard','Very Hard','Extreme'][difficulty.clamp(1,5) - 1]),
              if (urgency != null)
                _detailRow(Icons.speed, 'Urgency', ['Low','Medium-Low','Medium','Medium-High','High'][urgency.clamp(1,5) - 1]),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF777587)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF777587)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF191C1D)),
            ),
          ),
        ],
      ),
    );
  }
}
