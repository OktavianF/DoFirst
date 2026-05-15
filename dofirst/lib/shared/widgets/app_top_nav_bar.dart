import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/notifications/presentation/notifications_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/profile/presentation/profile_view_model.dart';
import '../theme/app_theme.dart';

class AppTopNavBar extends StatelessWidget {
  const AppTopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final profileVm = context.watch<ProfileViewModel>();
    final initial = profileVm.fullName.isNotEmpty
        ? profileVm.fullName[0].toUpperCase()
        : '?';

    return Container(
      height: 57,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 96,
            height: 54,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 54),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: const Key('home_notifications_button'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.notifications_none,
                  size: 28,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              InkWell(
                key: const Key('home_profile_button'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
                customBorder: const CircleBorder(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE2DFFF),
                      width: 4.0,
                    ),
                    color: Colors.grey[300],
                  ),
                  child: ClipOval(
                    child: profileVm.avatarUrl != null
                        ? Image.network(
                            profileVm.avatarUrl!,
                            width: 34,
                            height: 34,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildAvatarFallback(initial),
                          )
                        : _buildAvatarFallback(initial),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String initial) {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
