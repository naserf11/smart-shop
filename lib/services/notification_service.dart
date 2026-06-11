import '../models/app_notification.dart';

class NotificationService {
  final List<AppNotification>
      _notifications = [];

  List<AppNotification>
      get notifications =>
          _notifications;

  void addNotification(
      AppNotification notification) {
    _notifications.add(notification);
  }

  void markAsRead(String id) {
    final notification =
        _notifications.firstWhere(
      (n) => n.id == id,
    );

    notification.isRead = true;
  }

  int unreadCount() {
    return _notifications
        .where((n) => !n.isRead)
        .length;
  }
}