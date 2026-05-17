import 'dart:io';
import 'package:http/http.dart' as http;
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
    String? attachment,
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
        'attachment': attachment,
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

  Future<Map<String, dynamic>> updateTask(String id, Map<String, dynamic> data) async {
    final response = await ApiClient.put('/tasks/$id', body: data);
    return response['data'] as Map<String, dynamic>;
  }

  Future<void> deleteTask(String id) async {
    await ApiClient.delete('/tasks/$id');
  }

  Future<void> completeTask(String id) async {
    await ApiClient.post('/tasks/$id/complete', body: {});
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await ApiClient.get('/dashboard');
    return response['data'] as Map<String, dynamic>;
  }

  /// Upload a file attachment to a task via multipart POST
  Future<Map<String, dynamic>> uploadTaskAttachment(String taskId, File file) async {
    final token = await ApiClient.getToken();
    final uri = Uri.parse('${ApiClient.baseUrl}/upload/task-attachment/$taskId');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode != 200 && streamedResponse.statusCode != 201) {
      throw ApiException('Upload failed: ${streamedResponse.statusCode}');
    }

    final decoded = ApiClient.decodeJson(responseBody);
    return decoded['data'] as Map<String, dynamic>;
  }
}
