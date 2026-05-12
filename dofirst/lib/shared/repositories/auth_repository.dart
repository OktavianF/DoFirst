import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_client.dart';

class AuthRepository {
  Map<String, dynamic>? _extractSession(Map<String, dynamic> data) {
    final session = data['session'];
    if (session is Map<String, dynamic>) {
      return session;
    }

    final accessToken = data['accessToken'] ?? data['access_token'];
    final refreshToken = data['refreshToken'] ?? data['refresh_token'];
    final expiresAt = data['expiresAt'] ?? data['expires_at'];

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      ...?(expiresAt == null ? null : {'expiresAt': expiresAt}),
    };
  }

  Future<void> _persistSession(Map<String, dynamic> data) async {
    final session = _extractSession(data);
    if (session == null) return;

    await ApiClient.saveTokens(
      accessToken: session['accessToken'] as String? ?? '',
      refreshToken: session['refreshToken'] as String? ?? '',
    );
    await ApiClient.saveLoginTimestamp();
  }

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
    await _persistSession(data);

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
    await _persistSession(data);

    return data;
  }

  /// Sign in with Google — triggers native Google sign-in flow,
  /// sends ID token to backend for Supabase verification.
  Future<Map<String, dynamic>> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize(
      clientId: '1075110912203-o3cl8onk5pc2o2bfaujb6jv93ufinbfj.apps.googleusercontent.com',
      serverClientId: null,
    );

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
    await _persistSession(data);

    return data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await ApiClient.get('/auth/me');
    return response['data'] as Map<String, dynamic>;
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.disconnect();
    } catch (_) {
      // Some platforms and tests do not implement Google Sign-In disconnect.
    }
    await ApiClient.clearTokens();
  }
}
