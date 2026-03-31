import '../services/api_client.dart';

class TaskRepository {
  Future<Map<String, dynamic>> createTask({
    required String title,
    String? description,
    int importance = 3,
    int difficulty = 3,
    int urgency = 3,
    String? deadline,
    List<String>? tags,
  }) async {
    final response = await ApiClient.post(
      '/tasks',
      body: {
        'title': title,
        'description': description,
        'importance': importance,
        'difficulty': difficulty,
        'urgency': urgency,
        'deadline': deadline,
        'tags': tags,
      },
    );
    return response['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final response = await ApiClient.get('/tasks');
    final data = response['data'] as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getTask(String id) async {
    final response = await ApiClient.get('/tasks/$id');
    return response['data'] as Map<String, dynamic>;
  }

  Future<void> completeTask(String id) async {
    await ApiClient.delete('/tasks/$id/complete');
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await ApiClient.get('/dashboard');
    return response['data'] as Map<String, dynamic>;
  }
}
