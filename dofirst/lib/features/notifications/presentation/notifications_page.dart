import 'package:flutter/material.dart';

import '../../tasks/presentation/task_list/task_list_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Center(
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
                  color: Color(0xFFF3F2FF), // light purple background
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_none,
                    size: 60,
                    color: Color(0xFF8E88E5), // soft purple icon
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Quiet for now',
                style: TextStyle(
fontWeight: FontWeight.w800,
                  fontSize: 24.0,
                  color: Color(0xFF191C1D),
                ),
              ),
              const SizedBox(height: 16),
              
              // Subtitle with colored text
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
                        color: Color(0xFF5E54D8), // matched purple text
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(text: ' while things are calm.'),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // View Tasks button
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
                          Icon(
                            Icons.rocket_launch_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
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
              
              // Bottom info text
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Color(0xFFC7C4D8),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Notifications appear here as they arrive',
                    style: TextStyle(
fontSize: 12.0,
                      color: Color(0xFFC7C4D8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
