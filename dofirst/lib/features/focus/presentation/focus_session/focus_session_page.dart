import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/repositories/task_repository.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../success/presentation/success_page.dart';
import 'focus_session_view_model.dart';

class FocusSessionPage extends StatelessWidget {
  final String taskName;
  final String? taskId;

  const FocusSessionPage({super.key, this.taskName = 'Finish PRD Draft', this.taskId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FocusSessionViewModel(),
      child: _FocusSessionContent(taskName: taskName, taskId: taskId),
    );
  }
}

class _FocusSessionContent extends StatelessWidget {
  final String taskName;
  final String? taskId;

  const _FocusSessionContent({required this.taskName, this.taskId});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FocusSessionViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    // Active Task Display
                    Text(
                      viewModel.isBreakMode ? 'TAKING A BREAK' : 'CURRENTLY FOCUSING',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.isBreakMode
                          ? 'Stretch your body or take a short walk!'
                          : taskName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: viewModel.isBreakMode ? AppColors.inputFill : AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer, 
                                size: 14, 
                                color: viewModel.isBreakMode ? AppColors.textSecondary : Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Focus: 25m',
                                style: TextStyle(
                                  color: viewModel.isBreakMode ? AppColors.textSecondary : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: viewModel.isBreakMode ? AppColors.primary : AppColors.inputFill,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.coffee,
                                size: 14,
                                color: viewModel.isBreakMode ? Colors.white : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Break: 5m',
                                style: TextStyle(
                                  color: viewModel.isBreakMode ? Colors.white : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Central Timer Display
                    _buildProgressTimer(context, viewModel),

                    const Spacer(),

                    // Timer Controls
                    _buildControls(viewModel),
                    const SizedBox(height: 24),

                    // Finish Action
                    _buildFinishAction(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTimer(
    BuildContext context,
    FocusSessionViewModel viewModel,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 288,
          height: 288,
          child: CircularProgressIndicator(
            value: viewModel.progress,
            strokeWidth: 8,
            backgroundColor: AppColors.inputFill,
            color: AppColors.primary,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              viewModel.timeString,
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -2,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  viewModel.isBreakMode ? 'Break Session' : 'Focus Session',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls(FocusSessionViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: viewModel.toggleTimer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(viewModel.isRunning ? Icons.pause : Icons.play_arrow),
            label: Text(
              viewModel.isRunning ? 'Pause' : 'Start',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: viewModel.stopTimer,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              backgroundColor: AppColors.background,
              side: const BorderSide(color: AppColors.cardBorder),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.restart_alt),
            label: const Text(
              'Reset',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinishAction(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Are you sure?',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                      'Do you want to finish this task and archive it?',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          // Delete the task via API
                          if (taskId != null) {
                            try {
                              await TaskRepository().completeTask(taskId!);
                            } catch (_) {
                              // Continue even if delete fails
                            }
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const SuccessPage(),
                              ),
                            );
                          }
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.primary, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.check_circle),
            label: const Text(
              "Task's Finished",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Marking this as finished will archive the PRD task.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
