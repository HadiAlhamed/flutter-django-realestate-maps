import 'package:real_estate/models/notifications/notification.dart'
    as my_notificaiton;

class PaginatedNotifications {
  final String? nextUrl;
  final List<my_notificaiton.Notification> notifications;
  PaginatedNotifications({
    this.nextUrl,
    required this.notifications,
  });
  factory PaginatedNotifications.fromJson(Map<String, dynamic> json) {
    return PaginatedNotifications(
      nextUrl: json['next'],
      notifications: (json['results'] as List).map((notification) {
        return my_notificaiton.Notification.fromJson(notification);
      }).toList(),
    );
  }
}
