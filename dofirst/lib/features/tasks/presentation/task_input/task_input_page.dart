import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../home/presentation/home_view_model.dart';
import '../../../profile/presentation/profile_view_model.dart';
import '../task_list/task_list_view_model.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'task_input_view_model.dart';

class TaskInputPage extends StatelessWidget {
  const TaskInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskInputViewModel(),
      child: const _TaskInputContent(),
    );
  }
}

class _TaskInputContent extends StatefulWidget {
  const _TaskInputContent();

  @override
  State<_TaskInputContent> createState() => _TaskInputContentState();
}

class _TaskInputContentState extends State<_TaskInputContent> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context, TaskInputViewModel viewModel) async {
    FocusScope.of(context).unfocus();
    final success = await viewModel.saveTask();
    if (success && context.mounted) {
      context.read<HomeViewModel>().loadDashboard();
      context.read<TaskListViewModel>().loadTasks();
      context.read<ProfileViewModel>().loadProfile();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task saved successfully')),
      );
      Navigator.of(context).pop();
    } else if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Failed to save task')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TaskInputViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF777587)),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Add New Task',
          style: TextStyle(
color: Color(0xFF191C1D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: const [],
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
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
                      child: Text(
                        'THE GOAL',
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
fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF191C1D),
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'What needs to be done?',
                        hintStyle: TextStyle(
                          color: const Color(0xFF777587).withValues(alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildScaleSection(
                      'IMPORTANCE',
                      'Level ${viewModel.importance}',
                      viewModel.importance,
                      viewModel.updateImportance,
                    ),
                    const SizedBox(height: 24),
                    _buildScaleSection(
                      'DIFFICULTY',
                      ['Easy', 'Medium', 'Hard', 'Very Hard', 'Extreme'][viewModel.difficulty - 1],
                      viewModel.difficulty,
                      viewModel.updateDifficulty,
                    ),
                    const SizedBox(height: 24),
                    _buildScaleSection(
                      'URGENCY',
                      ['Low', 'Medium-Low', 'Medium', 'Medium-High', 'High'][viewModel.urgency - 1],
                      viewModel.urgency,
                      viewModel.updateUrgency,
                    ),
                    const SizedBox(height: 40),
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
                      child: Text(
                        'DEADLINE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Color(0xFF777587),
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildDeadlineChip('Today', viewModel, hasIcon: true),
                        _buildDeadlineChip('Tomorrow', viewModel),
                        _buildDeadlineChip('Next Week', viewModel),
                        if (!['Today', 'Tomorrow', 'Next Week'].contains(viewModel.deadline))
                          _buildDeadlineChip(viewModel.deadline, viewModel, hasIcon: true),
                        _buildCalendarChip(context, viewModel),
                      ],
                    ),
                    const SizedBox(height: 24),

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
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: MaterialButton(
              onPressed: viewModel.isValid ? () => _onSave(context, viewModel) : null,
              color: const Color(0xFF4F46E5),
              disabledColor: const Color(0xFF4F46E5).withValues(alpha: 0.5),
              elevation: 0,
              highlightElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (viewModel.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  else ...[
                    const Icon(Icons.add_task, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      'Add Task',
                      style: TextStyle(
color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScaleSection(String title, String subtitle, int currentValue, Function(int) onChanged) {
    const activeColor = Color(0xFF4F46E5);
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

  Widget _buildDeadlineChip(String text, TaskInputViewModel viewModel, {bool hasIcon = false}) {
    final isSelected = viewModel.deadline == text;
    return GestureDetector(
      onTap: () => viewModel.updateDeadline(text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F5),
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasIcon) ...[
              Icon(Icons.event, size: 16, color: isSelected ? Colors.white : const Color(0xFF777587)),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF777587),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarChip(BuildContext context, TaskInputViewModel viewModel) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF4F46E5),
                  onPrimary: Colors.white,
                  onSurface: Color(0xFF191C1D),
                ),
              ),
              child: child!,
            );
          },
        );
        
        if (date != null && context.mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF4F46E5),
                    onPrimary: Colors.white,
                    onSurface: Color(0xFF191C1D),
                  ),
                ),
                child: child!,
              );
            },
          );

          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          var formattedDate = '${months[date.month - 1]} ${date.day}, ${date.year}';

          if (time != null) {
            final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
            final minute = time.minute.toString().padLeft(2, '0');
            final period = time.period == DayPeriod.am ? 'AM' : 'PM';
            formattedDate += ' $hour:$minute $period';
          }

          viewModel.updateDeadline(formattedDate);
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F5),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFC7C4D8).withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.calendar_today, size: 16, color: Color(0xFF777587)),
      ),
    );
  }
}
