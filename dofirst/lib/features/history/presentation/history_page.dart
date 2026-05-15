import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                              children: const [
                                SizedBox(height: 120),
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.history, size: 64, color: Color(0xFFBBBBBB)),
                                      SizedBox(height: 16),
                                      Text(
                                        'No completed tasks yet',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          color: Color(0xFF777587),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Complete a task to see it here!',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          color: Color(0xFF999999),
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
                                      const Text(
                                        'History',
                                        style: TextStyle(
                                          fontFamily: 'Lexend',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32,
                                          color: Color(0xFF191C1D),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      Text(
                                        '${vm.total} tasks',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          color: Color(0xFF777587),
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
}
