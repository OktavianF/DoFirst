import '../services/api_client.dart';

class SettingsRepository {
  Future<Map<String, dynamic>> getSettings() async {
    final response = await ApiClient.get('/settings');
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> data) async {
    final response = await ApiClient.put('/settings', body: data);
    return response['data'] as Map<String, dynamic>;
  }
}
