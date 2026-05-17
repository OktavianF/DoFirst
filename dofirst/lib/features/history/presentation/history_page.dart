import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/history_item_card.dart';
import 'history_view_model.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inDays == 0) {
      return 'Today, ${local.hour}:${local.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday, ${local.hour}:${local.minute.toString().padLeft(2, '0')}';
    } else {
      return '${local.day}/${local.month}/${local.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryViewModel(),
      child: Consumer<HistoryViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF191C1D)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SafeArea(
              child: vm.isLoading && vm.tasks.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => vm.loadHistory(refresh: true),
                      child: vm.tasks.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 120),
                                Center(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.history, size: 64, color: Color(0xFFBBBBBB)),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No completed tasks yet',
                                        style: GoogleFonts.lexend(
                                          fontSize: 16,
                                          color: const Color(0xFF777587),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Complete a task to see it here!',
                                        style: GoogleFonts.lexend(
                                          fontSize: 14,
                                          color: const Color(0xFF999999),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : NotificationListener<ScrollNotification>(
                              onNotification: (scroll) {
                                if (scroll is ScrollEndNotification &&
                                    scroll.metrics.extentAfter < 100 &&
                                    vm.hasMore) {
                                  vm.loadMore();
                                }
                                return false;
                              },
                              child: ListView(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                children: [
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'History',
                                        style: GoogleFonts.lexend(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32,
                                          color: const Color(0xFF191C1D),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      Text(
                                        '${vm.total} tasks',
                                        style: GoogleFonts.lexend(
                                          fontSize: 14,
                                          color: const Color(0xFF777587),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  ...vm.tasks.map((task) {
                                    return HistoryItemCard(
                                      title: task['title'] as String? ?? 'Untitled',
                                      subtitle: _formatDate(
                                        task['completedAt'] as String? ??
                                            task['completed_at'] as String?,
                                      ),
                                      onTap: () => _showCompletedTaskDetail(context, task),
                                    );
                                  }),
                                  if (vm.isLoading)
                                    const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(child: CircularProgressIndicator()),
                                    ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                    ),
            ),
          );
        },
      ),
    );
  }

  void _showCompletedTaskDetail(BuildContext context, Map<String, dynamic> task) {
    final title = task['title'] as String? ?? 'Untitled';
    final description = task['description'] as String?;
    final completedAt = task['completedAt'] as String? ?? task['completed_at'] as String?;
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

  Widget _detailRow(IconData icon, String label, String value) {
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
