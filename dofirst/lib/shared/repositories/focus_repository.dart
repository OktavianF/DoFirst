import '../services/api_client.dart';

class FocusRepository {
  Future<Map<String, dynamic>> recordSession({
    String? taskId,
    required int durationMinutes,
    String sessionType = 'focus',
  }) async {
    final response = await ApiClient.post('/focus/sessions', body: {
      'taskId': taskId,
      'durationMinutes': durationMinutes,
      'sessionType': sessionType,
    });
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await ApiClient.get('/focus/stats');
    return response['data'] as Map<String, dynamic>;
  }
}
