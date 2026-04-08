import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Global navigator key for 401 redirect
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ApiClient {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api', // default ke localhost jika tidak diset
  );

  static String get baseUrl => _baseUrl;

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  static Future<bool> hasToken() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

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
    return _handleResponse(response);
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
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(String path, {bool withAuth = true}) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
    );
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Handle 401 globally — redirect to login
    if (response.statusCode == 401) {
      _handleUnauthorized();
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: body['error']?.toString() ?? 'Unknown error',
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
