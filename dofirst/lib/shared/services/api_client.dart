import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


/// Global navigator key for 401 redirect
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ApiClient {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api', // default ke localhost jika tidak diset
  );

  /// Session validity duration — 1 week
  static const Duration _sessionDuration = Duration(days: 7);

  /// Whether a token refresh is already in progress (prevents concurrent refreshes)
  static bool _isRefreshing = false;

  static String get baseUrl => _baseUrl;

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  /// Save login timestamp to track session expiry (1 week)
  static Future<void> saveLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  /// Check if the session has expired (older than 1 week)
  static Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTs = prefs.getInt('login_timestamp');
    if (loginTs == null) return true;

    final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTs);
    return DateTime.now().difference(loginDate) > _sessionDuration;
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('login_timestamp');
    await prefs.remove('cached_dashboard');
    await prefs.remove('cached_tasks');
  }

  static Future<bool> hasToken() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return false;

    // Check if session has expired (>7 days since login)
    if (await isSessionExpired()) {
      await clearTokens();
      return false;
    }

    return true;
  }

  // ─── Cache Helpers ────────────────────────────────────────────

  /// Cache JSON data with a key
  static Future<void> cacheData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  /// Get cached JSON data by key
  static Future<dynamic> getCachedData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  // ─── Token Refresh ────────────────────────────────────────────

  /// Attempt to refresh the access token using the stored refresh token.
  /// Returns true if refresh was successful.
  static Future<bool> refreshAccessToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>?;
        final session = data?['session'] as Map<String, dynamic>?;

        if (session != null) {
          await saveTokens(
            accessToken: session['accessToken'] as String? ?? '',
            refreshToken: session['refreshToken'] as String? ?? '',
          );
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // ─── HTTP Methods ─────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (withAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(String path, {bool withAuth = true}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
    );
    return _handleResponse(response, path: path, method: 'GET', withAuth: withAuth);
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response, path: path, method: 'POST', body: body, withAuth: withAuth);
  }

  static Future<Map<String, dynamic>> delete(String path, {bool withAuth = true}) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
    );
    return _handleResponse(response, path: path, method: 'DELETE', withAuth: withAuth);
  }

  static Future<Map<String, dynamic>> _handleResponse(
    http.Response response, {
    String? path,
    String? method,
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    }

    // Handle 401 — try to refresh token before giving up
    if (response.statusCode == 401 && withAuth) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        // Retry the original request with new token
        http.Response retryResponse;
        final retryHeaders = await _headers(withAuth: true);

        if (method == 'POST') {
          retryResponse = await http.post(
            Uri.parse('$_baseUrl$path'),
            headers: retryHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
        } else if (method == 'DELETE') {
          retryResponse = await http.delete(
            Uri.parse('$_baseUrl$path'),
            headers: retryHeaders,
          );
        } else {
          retryResponse = await http.get(
            Uri.parse('$_baseUrl$path'),
            headers: retryHeaders,
          );
        }

        final retryBody = jsonDecode(retryResponse.body) as Map<String, dynamic>;
        if (retryResponse.statusCode >= 200 && retryResponse.statusCode < 300) {
          return retryBody;
        }

        // Retry also failed — redirect to login
        _handleUnauthorized();
        throw ApiException(
          statusCode: retryResponse.statusCode,
          message: retryBody['error']?.toString() ?? 'Session expired',
        );
      } else {
        // Refresh failed — redirect to login
        _handleUnauthorized();
      }
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: responseBody['error']?.toString() ?? 'Unknown error',
    );
  }

  static void _handleUnauthorized() async {
    await clearTokens();
    // Navigate to login using the global navigator key
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
