import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'edit_task_view_model.dart';
import '../../../home/presentation/home_view_model.dart';
import '../../../profile/presentation/profile_view_model.dart';
import '../task_list/task_list_view_model.dart';

class EditTaskPage extends StatelessWidget {
  final dynamic task;
  const EditTaskPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return _EditTaskContent(task: task);
  }
}

class _EditTaskContent extends StatefulWidget {
  final dynamic task;
  const _EditTaskContent({required this.task});

  @override
  State<_EditTaskContent> createState() => _EditTaskContentState();
}

class _EditTaskContentState extends State<_EditTaskContent> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  int titleLength = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description ?? '');
    titleLength = widget.task.title.length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<EditTaskViewModel>();
      vm.initFromTask(widget.task);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context, EditTaskViewModel viewModel) async {
    FocusScope.of(context).unfocus();
    final success = await viewModel.updateTask();
    if (success && context.mounted) {
      context.read<HomeViewModel>().loadDashboard();
      context.read<TaskListViewModel>().loadTasks();
      context.read<ProfileViewModel>().loadProfile();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully')),
      );
      Navigator.of(context).pop();
    } else if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Failed to update task')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditTaskViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF777587)),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Edit Task',
          style: TextStyle(
            color: Color(0xFF191C1D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Title field with Icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                                child: Text(
                                  'TASK TITLE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                    color: Color(0xFF777587),
                                  ),
                                ),
                              ),
                              TextField(
                                controller: _titleController,
                                onChanged: viewModel.updateTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF191C1D),
                                ),
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: 'What needs to be done?',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Priority Row
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: Text(
                        'Priority',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF777587),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF8B1A10),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'High Priority',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF191C1D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              '9.8',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF191C1D),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Importance, Difficulty, Urgency
                    _buildScaleSection(
                      'IMPORTANCE',
                      'Level ${viewModel.importance}',
                      viewModel.importance,
                      viewModel.updateImportance,
                    ),
                    const SizedBox(height: 16),
                    _buildScaleSection(
                      'DIFFICULTY',
                      ['Easy', 'Medium', 'Hard', 'Very Hard', 'Extreme'][viewModel.difficulty - 1],
                      viewModel.difficulty,
                      viewModel.updateDifficulty,
                    ),
                    const SizedBox(height: 16),
                    _buildScaleSection(
                      'URGENCY',
                      ['Low', 'Medium-Low', 'Medium', 'Medium-High', 'High'][viewModel.urgency - 1],
                      viewModel.urgency,
                      viewModel.updateUrgency,
                    ),
                    const SizedBox(height: 24),

                    // Due Date & Time
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: Text(
                        'Due Date & Time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF777587),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF777587)),
                              const SizedBox(width: 12),
                              Text(
                                viewModel.deadline,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF191C1D),
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF777587)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF777587),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFC7C4D8), width: 2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'To Do',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF191C1D),
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF777587)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF777587),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: _descController,
                            onChanged: viewModel.updateDescription,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF191C1D),
                            ),
                            textInputAction: TextInputAction.done,
                            maxLines: 4,
                            minLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add details here...',
                              hintStyle: TextStyle(
                                color: const Color(0xFF777587).withValues(alpha: 0.5),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Text(
                              '${_descController.text.length}/500',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF777587),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Attachment
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: Text(
                        'Attachment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF777587),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBA1A1A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('PDF', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  viewModel.attachmentName ?? 'Q4 Strategy Draft V2.pdf',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF191C1D),
                                  ),
                                ),
                                const Text(
                                  '2.4 MB',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF777587),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.file_download_outlined, color: Color(0xFF777587), size: 20),
                          const SizedBox(width: 16),
                          const Icon(Icons.close, color: Color(0xFF777587), size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    side: const BorderSide(color: Color(0xFF3F37C9), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
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
                child: MaterialButton(
                  onPressed: (viewModel.isValid && !viewModel.isLoading) ? () => _onSave(context, viewModel) : null,
                  color: const Color(0xFF3F37C9),
                  disabledColor: const Color(0xFF3F37C9).withValues(alpha: 0.5),
                  elevation: 0,
                  highlightElevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScaleSection(String title, String subtitle, int currentValue, Function(int) onChanged) {
    const activeColor = Color(0xFF3F37C9);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Color(0xFF777587),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final value = index + 1;
              final isSelected = value == currentValue;
              return GestureDetector(
                onTap: () => onChanged(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? null : Border.all(color: const Color(0xFFC7C4D8).withValues(alpha: 0.3)),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                            )
                          ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF777587),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
