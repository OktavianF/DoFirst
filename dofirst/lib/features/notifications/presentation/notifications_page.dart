import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../tasks/presentation/task_list/task_list_page.dart';
import 'notifications_view_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationsViewModel(),
      child: Consumer<NotificationsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF8F9FA),
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF3525CD)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Notifications',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191C1D),
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              actions: vm.notifications.isNotEmpty
                  ? [
                      TextButton(
                        onPressed: () => vm.markAllRead(),
                        child: const Text(
                          'Read All',
                          style: TextStyle(
                            color: Color(0xFF3525CD),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]
                  : null,
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.isEmpty
                    ? _buildEmptyState(context)
                    : _buildNotificationList(vm),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Purple circle with bell icon
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F2FF),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.notifications_none,
                  size: 60,
                  color: Color(0xFF8E88E5),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Quiet for now',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 24.0,
                color: Color(0xFF191C1D),
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 16.0,
                  color: Color(0xFF777587),
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: 'Enjoy the silence. Focus on your '),
                  TextSpan(
                    text: 'hero\ntask',
                    style: TextStyle(
                      color: Color(0xFF5E54D8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: ' while things are calm.'),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Container(
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
                    offset: const Offset(0, 10),
                    blurRadius: 20.0,
                    spreadRadius: -5.0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24.0),
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const TaskListPage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                      (route) => false,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.rocket_launch_outlined, color: Colors.white, size: 20),
                        SizedBox(width: 8.0),
                        Text(
                          'View Tasks',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 64),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 14, color: Color(0xFFC7C4D8)),
                SizedBox(width: 6),
                Text(
                  'Notifications appear here as they arrive',
                  style: TextStyle(fontSize: 12.0, color: Color(0xFFC7C4D8)),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(NotificationsViewModel vm) {
    return RefreshIndicator(
      onRefresh: () => vm.loadNotifications(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: vm.notifications.length,
        itemBuilder: (context, index) {
          final notif = vm.notifications[index];
          final isRead = notif['isRead'] == true || notif['is_read'] == true;
          final type = notif['type'] as String? ?? 'info';
          final createdAt = notif['createdAt'] as String? ?? notif['created_at'] as String?;

          IconData icon;
          Color iconColor;
          switch (type) {
            case 'deadline':
              icon = Icons.alarm;
              iconColor = const Color(0xFFE53E3E);
              break;
            case 'achievement':
              icon = Icons.emoji_events;
              iconColor = const Color(0xFFD69E2E);
              break;
            case 'reminder':
              icon = Icons.notifications_active;
              iconColor = const Color(0xFF3525CD);
              break;
            default:
              icon = Icons.info_outline;
              iconColor = const Color(0xFF777587);
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isRead ? Colors.white : const Color(0xFFF3F2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              title: Text(
                notif['title'] as String? ?? '',
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  fontSize: 14,
                  color: const Color(0xFF191C1D),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notif['message'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        notif['message'] as String,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF777587)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatTime(createdAt),
                        style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
                      ),
                    ),
                ],
              ),
              trailing: !isRead
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3525CD),
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              onTap: () {
                if (!isRead) {
                  vm.markRead(notif['id'] as String);
                }
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTime(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${local.day}/${local.month}/${local.year}';
  }
}
