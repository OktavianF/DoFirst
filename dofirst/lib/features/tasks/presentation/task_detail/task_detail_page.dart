import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../task_input/task_input_page.dart';
import '../task_list/task_list_view_model.dart';

class TaskDetailPage extends StatelessWidget {
  final TaskItem task;

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF191C1D)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Task Detail',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.0,
                      color: Color(0xFF191C1D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: const Color(0xFFF0F1F2)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF191C1D).withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Color(0xFF191C1D),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'SCORE ${task.score}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                            color: Color(0xFF777587),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    if (task.description != null)
                      Text(
                        task.description!,
                        style: const TextStyle(fontSize: 14.0, color: Color(0xFF464555)),
                      )
                    else
                      const Text('No description provided.', style: TextStyle(fontSize: 14.0, color: Color(0xFF777587))),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Color(0xFF777587)),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Assigned to: You',
                            style: TextStyle(color: Color(0xFF777587)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF777587)),
                        const SizedBox(width: 8),
                        Text(
                          TaskItem.formatDeadline(task.deadline),
                          style: const TextStyle(color: Color(0xFF777587)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    const Divider(),
                    const SizedBox(height: 12.0),
                    const Text(
                      'Attachments',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191C1D),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: const Color(0xFFF0F1F2)),
                      ),
                      child: Row(
                        children: const [
                          _AttachmentIcon(),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Q4 Strategy Draft V2.pdf',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF191C1D),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '2.4 MB',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777587),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TaskInputPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3525CD),
                        side: const BorderSide(color: Color(0xFF6C63FF), width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_outlined, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Edit Task',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _confirmDelete(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEA4335),
                        side: const BorderSide(color: Color(0xFFEA4335), width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Delete Task',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete task?'),
          content: const Text('Task ini akan dihapus dari daftar. Lanjutkan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFEA4335)),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    await context.read<TaskListViewModel>().completeTask(task.id);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted successfully')),
    );
    Navigator.of(context).pop();
  }
}

class _AttachmentIcon extends StatelessWidget {
  const _AttachmentIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFEA4335),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Icon(Icons.picture_as_pdf, size: 16, color: Colors.white),
    );
  }
}
