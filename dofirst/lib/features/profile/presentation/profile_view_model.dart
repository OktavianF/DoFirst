import 'package:flutter/material.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/task_repository.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/services/user_preferences_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  final TaskRepository _taskRepo = TaskRepository();

  String _fullName = '';
  String _email = '';
  String? _avatarUrl;
  int _totalTasks = 0;

  bool _isLoading = true;
  String? _errorMessage;

  String get fullName => _fullName;
  String get email => _email;
  String? get avatarUrl => _avatarUrl;
  int get totalTasks => _totalTasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProfileViewModel() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch profile and dashboard in parallel
      final results = await Future.wait([
        _authRepo.getMe(),
        _taskRepo.getDashboard(),
      ]);

      final meData = results[0];
      final dashData = results[1];

      final profile = meData['profile'] as Map<String, dynamic>?;
        final savedDisplayName = await UserPreferencesService.getProfileDisplayName();
        final savedAvatarUrl = await UserPreferencesService.getProfileAvatarUrl();

        _fullName = savedDisplayName?.trim().isNotEmpty == true
          ? savedDisplayName!.trim()
          : profile?['fullName'] as String? ?? 'User';
      _email = meData['email'] as String? ?? '';
        _avatarUrl = savedAvatarUrl?.trim().isNotEmpty == true
          ? savedAvatarUrl!.trim()
          : profile?['avatarUrl'] as String?;
      _totalTasks = dashData['totalTasks'] as int? ?? 0;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load profile';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _fullName = '';
    _email = '';
    _avatarUrl = null;
    _totalTasks = 0;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    final normalizedName = fullName.trim();
    if (normalizedName.isNotEmpty) {
      _fullName = normalizedName;
      await UserPreferencesService.saveProfileDisplayName(normalizedName);
    }

    final normalizedAvatar = avatarUrl?.trim();
    if (normalizedAvatar != null) {
      _avatarUrl = normalizedAvatar.isEmpty ? null : normalizedAvatar;
      await UserPreferencesService.saveProfileAvatarUrl(_avatarUrl);
    }

    notifyListeners();
  }
}
