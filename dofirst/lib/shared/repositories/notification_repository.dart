import '../services/api_client.dart';

class NotificationRepository {
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await ApiClient.get('/notifications');
    final data = response['data'] as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> markRead(String id) async {
    await ApiClient.put('/notifications/$id/read', body: {});
  }

  Future<void> markAllRead() async {
    await ApiClient.put('/notifications/read-all', body: {});
  }

  Future<int> getUnreadCount() async {
    final response = await ApiClient.get('/notifications/unread-count');
    final data = response['data'] as Map<String, dynamic>;
    return data['count'] as int? ?? 0;
  }
}
