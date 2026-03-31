import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_client.dart';

class AuthRepository {
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/auth/signup',
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
      },
      withAuth: false,
    );

    final data = response['data'] as Map<String, dynamic>;
    final session = data['session'] as Map<String, dynamic>?;

    if (session != null) {
      await ApiClient.saveTokens(
        accessToken: session['accessToken'] as String? ?? '',
        refreshToken: session['refreshToken'] as String? ?? '',
      );
    }

    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      withAuth: false,
    );

    final data = response['data'] as Map<String, dynamic>;
    final session = data['session'] as Map<String, dynamic>?;

    if (session != null) {
      await ApiClient.saveTokens(
        accessToken: session['accessToken'] as String? ?? '',
        refreshToken: session['refreshToken'] as String? ?? '',
      );
    }

    return data;
  }

  /// Sign in with Google — triggers native Google sign-in flow,
  /// sends ID token to backend for Supabase verification.
  Future<Map<String, dynamic>> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    final account = await googleSignIn.authenticate();

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw ApiException(statusCode: 0, message: 'Failed to get Google ID token');
    }

    final response = await ApiClient.post(
      '/auth/google',
      body: {'idToken': idToken},
      withAuth: false,
    );

    final data = response['data'] as Map<String, dynamic>;
    final session = data['session'] as Map<String, dynamic>?;

    if (session != null) {
      await ApiClient.saveTokens(
        accessToken: session['accessToken'] as String? ?? '',
        refreshToken: session['refreshToken'] as String? ?? '',
      );
    }

    return data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await ApiClient.get('/auth/me');
    return response['data'] as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await GoogleSignIn.instance.disconnect();
    await ApiClient.clearTokens();
  }
}
