import 'package:flutter/foundation.dart';
import '../core/constants/api_endpoints.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiEndpoints.notifications);
      if (response.success && response.data != null) {
        final list = response.data as List;
        _notifications =
            list.map((item) => NotificationModel.fromJson(item)).toList();
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    final response = await ApiService.patch(ApiEndpoints.readNotification(id));
    if (response.success) {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final current = _notifications[index];
        _notifications[index] = NotificationModel(
          id: current.id,
          storeId: current.storeId,
          userId: current.userId,
          title: current.title,
          message: current.message,
          type: current.type,
          isRead: true,
          createdAt: current.createdAt,
        );
        notifyListeners();
      }
    }
  }
}
