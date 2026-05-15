import 'package:flutter/foundation.dart';
import '../../../shared/repositories/history_repository.dart';
import '../../../shared/services/api_client.dart';

class HistoryViewModel extends ChangeNotifier {
  final HistoryRepository _historyRepo = HistoryRepository();

  List<Map<String, dynamic>> _tasks = [];
  int _total = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get tasks => _tasks;
  int get total => _total;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _currentPage < _totalPages;

  HistoryViewModel() {
    loadHistory();
  }

  Future<void> loadHistory({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _tasks = [];
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _historyRepo.getHistory(page: _currentPage);
      final tasks = data['tasks'] as List<dynamic>? ?? [];

      if (refresh || _currentPage == 1) {
        _tasks = tasks.cast<Map<String, dynamic>>();
      } else {
        _tasks.addAll(tasks.cast<Map<String, dynamic>>());
      }

      _total = data['total'] as int? ?? 0;
      _totalPages = data['totalPages'] as int? ?? 1;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load history';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || _isLoading) return;
    _currentPage++;
    await loadHistory();
  }

  void clearState() {
    _tasks = [];
    _total = 0;
    _currentPage = 1;
    _totalPages = 1;
    _errorMessage = null;
    notifyListeners();
  }
}
