import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/theme/app_theme.dart';
import '../task_list/task_list_view_model.dart';
import '../task_input/edit_task_page.dart';
import '../task_input/edit_task_view_model.dart';
import '../../../home/presentation/home_view_model.dart';
import '../../../profile/presentation/profile_view_model.dart';

class TaskDetailPage extends StatefulWidget {
  final TaskItem task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TaskItem _task;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  /// Refresh the task data from the ViewModel after returning from Edit
  void _refreshTask() {
    final vm = context.read<TaskListViewModel>();
    try {
      final updated = vm.allTasks.firstWhere((t) => t.id == _task.id);
      setState(() => _task = updated);
    } catch (_) {
      // Task may have been deleted or completed, pop immediately
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  String _formatCreatedDate(DateTime? dt) {
    if (dt == null) return 'Unknown date';
    final local = dt.toLocal();
    return '${_months[local.month - 1]} ${local.day}, ${local.year}';
  }

  String _formatCreatedTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${local.minute.toString().padLeft(2, '0')} $ampm';
  }

  bool _isImageFile(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png') || lower.endsWith('.gif') || lower.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF464555)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Task Detail',
          style: TextStyle(
            color: Color(0xFF191C1D),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _task.priority == 'HIGH'
                                    ? const Color(0xFF8B1A10)
                                    : _task.priority == 'MEDIUM'
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_task.priority} PRIORITY',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: _task.priority == 'HIGH'
                                    ? const Color(0xFF8B1A10)
                                    : _task.priority == 'MEDIUM'
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5F5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'SCORE ${_task.score}',
                            style: const TextStyle(
                              color: Color(0xFF464555),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Color(0xFF8B1A10),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _task.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191C1D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF777587)),
                        const SizedBox(width: 8),
                        Text(
                          _task.timeText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF777587),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'DESCRIPTION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Color(0xFF777587),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _task.description ?? 'No description provided for this task.',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF777587),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ASSIGNED TO',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF777587),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFFE2DFFF),
                                    child: const Icon(Icons.person, size: 20, color: Color(0xFF3F37C9)),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'YOU',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF191C1D),
                                        ),
                                      ),
                                      Text(
                                        'Product Manager',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF777587),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CREATED',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF777587),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 20, color: Color(0xFF777587)),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatCreatedDate(_task.createdAt),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF191C1D),
                                        ),
                                      ),
                                      Text(
                                        _formatCreatedTime(_task.createdAt),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF777587),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_task.fileUrl != null) ...[
                    const Text(
                      'ATTACHMENTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Color(0xFF777587),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Image preview if it's an image file
                    if (_isImageFile(_task.fileUrl!))
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.tryParse(_task.fileUrl!);
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2DFFF)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _task.fileUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image, size: 48, color: Color(0xFF777587)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // File info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3525CD),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.attach_file, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              Uri.tryParse(_task.fileUrl!)?.pathSegments.last ?? 'Attachment',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF191C1D),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Download / Open button
                          GestureDetector(
                            onTap: () async {
                              final uri = Uri.tryParse(_task.fileUrl!);
                              if (uri != null) {
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Could not open attachment.')),
                                    );
                                  }
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2DFFF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.download, color: Color(0xFF3525CD), size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider<EditTaskViewModel>(
                              create: (_) => EditTaskViewModel(),
                              child: EditTaskPage(task: _task),
                            ),
                          ),
                        );
                        // After returning from edit, reload tasks and refresh
                        if (mounted) {
                          await context.read<TaskListViewModel>().loadTasks();
                          _refreshTask();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF3F37C9), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.edit, color: Color(0xFF3F37C9), size: 18),
                      label: const Text(
                        'Edit Task',
                        style: TextStyle(
                          color: Color(0xFF3F37C9),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A), size: 18),
                      label: const Text(
                        'Delete Task',
                        style: TextStyle(
                          color: Color(0xFFBA1A1A),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Task', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final vm = context.read<TaskListViewModel>();
                await vm.deleteTask(_task.id);
                if (context.mounted) {
                  context.read<HomeViewModel>().loadDashboard();
                  context.read<ProfileViewModel>().loadProfile();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA1A1A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
