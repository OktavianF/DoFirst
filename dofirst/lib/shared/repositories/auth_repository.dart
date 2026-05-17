import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
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
      await ApiClient.saveLoginTimestamp();
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
      await ApiClient.saveLoginTimestamp();
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
      throw ApiException('Failed to get Google ID token', statusCode: 0);
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
      await ApiClient.saveLoginTimestamp();
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

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await ApiClient.post(
      '/auth/forgot-password',
      body: {'email': email},
      withAuth: false,
    );
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

    final response = await ApiClient.put('/profile', body: body);
    return response['data'] as Map<String, dynamic>;
  }

  /// Upload avatar image to backend via multipart POST
  Future<Map<String, dynamic>> uploadAvatar(File file) async {
    final token = await ApiClient.getToken();
    final uri = Uri.parse('${ApiClient.baseUrl}/upload/avatar');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode != 200) {
      throw ApiException('Upload failed: ${streamedResponse.statusCode}');
    }

    final decoded = ApiClient.decodeJson(responseBody);
    return decoded['data'] as Map<String, dynamic>;
  }
}
