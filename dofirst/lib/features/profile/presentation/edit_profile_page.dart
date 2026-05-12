import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../shared/services/avatar_picker_service.dart';
import '../../../shared/services/user_preferences_service.dart';
import '../../../shared/widgets/app_avatar.dart';
import 'profile_view_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _avatarUrlController;

  @override
  void initState() {
    super.initState();
    final profileVm = context.read<ProfileViewModel>();
    _fullNameController = TextEditingController(text: profileVm.fullName);
    _emailController = TextEditingController(text: profileVm.email);
    _avatarUrlController = TextEditingController(text: profileVm.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileVm = context.watch<ProfileViewModel>();
    final displayName = _fullNameController.text.isNotEmpty
        ? _fullNameController.text
        : profileVm.fullName;
    final avatarUrl = _avatarUrlController.text.isNotEmpty
        ? _avatarUrlController.text
        : profileVm.avatarUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF667085)),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AppAvatar(
                        source: avatarUrl,
                        fallbackText: displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                        size: 92,
                        borderWidth: 4,
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2DFFF), width: 1.5),
                          ),
                          child: const Icon(Icons.photo_camera_outlined, size: 16, color: Color(0xFF4338CA)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Tap on the photo to change your profile picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB8B6C9),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Full Name',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              _EditableRowField(
                controller: _fullNameController,
                icon: Icons.person_outline,
                trailingIcon: Icons.edit_outlined,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              const Text(
                'Email',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              _EditableRowField(
                controller: _emailController,
                icon: Icons.email_outlined,
                trailingIcon: Icons.edit_outlined,
                readOnly: false,
                onChanged: (_) => setState(() {}),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await context.read<ProfileViewModel>().updateProfile(
                          fullName: _fullNameController.text,
                          avatarUrl: _avatarUrlController.text,
                        );
                    await UserPreferencesService.saveProfileDisplayName(_fullNameController.text);
                    await UserPreferencesService.saveProfileAvatarUrl(_avatarUrlController.text);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shadowColor: const Color(0x664F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final picked = await AvatarPickerService.pickAvatarDataUrl();
    if (!mounted || picked == null || picked.isEmpty) {
      return;
    }

    setState(() {
      _avatarUrlController.text = picked;
    });
  }
}

class _EditableRowField extends StatelessWidget {
  const _EditableRowField({
    required this.controller,
    required this.icon,
    required this.trailingIcon,
    this.onChanged,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final IconData icon;
  final IconData trailingIcon;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1D).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF4F46E5)),
          suffixIcon: Icon(trailingIcon, color: const Color(0xFF4F46E5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}