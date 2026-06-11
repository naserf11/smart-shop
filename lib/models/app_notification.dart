class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    this.isRead = false,
  });
}