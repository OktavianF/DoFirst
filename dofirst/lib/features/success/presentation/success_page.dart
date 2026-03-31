import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dofirst/features/home/presentation/home_view_model.dart';
import 'package:dofirst/features/tasks/presentation/task_list/task_list_view_model.dart';
import 'package:dofirst/shared/theme/app_theme.dart';
import 'package:dofirst/shared/widgets/primary_button.dart';

class SuccessPage extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const SuccessPage({
    super.key,
    this.title = 'Great Job!',
    this.message = 'You have successfully completed your task.',
    this.buttonText = 'Continue',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Success Icon/Illustration with Animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          color: AppColors.mintGlow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 80,
                        ),
                      ),
                      // Decorative elements around the circle
                      const Positioned(
                        top: -10,
                        right: -10,
                        child: Icon(
                          Icons.auto_awesome,
                          color: Colors.amber,
                          size: 40,
                        ),
                      ),
                      const Positioned(
                        bottom: 10,
                        left: -20,
                        child: Icon(
                          Icons.star_rounded,
                          color: Colors.orangeAccent,
                          size: 32,
                        ),
                      ),
                      const Positioned(
                        top: 40,
                        left: -30,
                        child: Icon(
                          Icons.auto_awesome_mosaic,
                          color: Colors.blueAccent,
                          size: 28,
                        ),
                      ),
                      const Positioned(
                        bottom: -5,
                        right: -15,
                        child: Icon(
                          Icons.celebration_rounded,
                          color: Colors.greenAccent,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              PrimaryButton(
                label: buttonText,
                onPressed: onPressed ?? () {
                  // Refresh data after task completion
                  context.read<HomeViewModel>().loadDashboard();
                  context.read<TaskListViewModel>().loadTasks();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
