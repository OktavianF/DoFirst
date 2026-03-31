import 'package:flutter/material.dart';
import '../../../../shared/repositories/auth_repository.dart';
import '../../../../shared/services/api_client.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _isFormValid = false;
  bool _hasInteracted = false;
  String? _errorMessage;

  bool get obscurePassword => _obscurePassword;
  bool get isSubmitting => _isSubmitting;
  bool get canSubmit => !_isSubmitting;
  bool get isFormValid => _isFormValid;
  String? get errorMessage => _errorMessage;

  AutovalidateMode get autovalidateMode => _hasInteracted
      ? AutovalidateMode.onUserInteraction
      : AutovalidateMode.disabled;

  void markInteracted() {
    if (_hasInteracted) return;
    _hasInteracted = true;
    notifyListeners();
  }

  void updateFormValidity(bool isValid) {
    if (_isFormValid == isValid) return;
    _isFormValid = isValid;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<bool> loginWithApi(String email, String password) async {
    _errorMessage = null;
    _isSubmitting = true;
    notifyListeners();

    try {
      await _authRepo.login(email: email, password: password);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Connection error. Is the server running?';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle() async {
    _errorMessage = null;
    _isSubmitting = true;
    notifyListeners();

    try {
      await _authRepo.signInWithGoogle();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, stacktrace) {
      print('Google sign in error: $e');
      print('Stacktrace: $stacktrace');
      _errorMessage = 'Google sign-in failed: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Legacy submit method kept for backward compatibility
  Future<void> submit(Future<void> Function() action) async {
    if (!canSubmit) return;

    _isSubmitting = true;
    notifyListeners();

    try {
      await action();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
