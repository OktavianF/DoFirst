import '../services/api_client.dart';

class HistoryRepository {
  Future<Map<String, dynamic>> getHistory({int page = 1, int limit = 20}) async {
    final response = await ApiClient.get('/history?page=$page&limit=$limit');
    return response['data'] as Map<String, dynamic>;
  }
}
