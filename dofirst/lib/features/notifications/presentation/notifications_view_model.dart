import 'package:flutter/foundation.dart';
import '../../../shared/repositories/notification_repository.dart';
import '../../../shared/services/api_client.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationRepository _notifRepo = NotificationRepository();

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isEmpty => _notifications.isEmpty;
  String? get errorMessage => _errorMessage;

  NotificationsViewModel() {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _notifRepo.getNotifications();
      _unreadCount = _notifications.where((n) => n['isRead'] != true && n['is_read'] != true).length;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load notifications';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _notifRepo.markRead(id);
      final idx = _notifications.indexWhere((n) => n['id'] == id);
      if (idx != -1) {
        _notifications[idx]['isRead'] = true;
        _notifications[idx]['is_read'] = true;
        _unreadCount = _notifications.where((n) => n['isRead'] != true && n['is_read'] != true).length;
        notifyListeners();
      }
    } catch (e) {
      // Silent fail for mark-read
    }
  }

  Future<void> markAllRead() async {
    try {
      await _notifRepo.markAllRead();
      for (var n in _notifications) {
        n['isRead'] = true;
        n['is_read'] = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await _notifRepo.getUnreadCount();
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }

  void clearState() {
    _notifications = [];
    _unreadCount = 0;
    _errorMessage = null;
    notifyListeners();
  }
}
