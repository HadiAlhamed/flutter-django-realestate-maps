import 'package:flutter/material.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/widgets/notifications_widgets/notification_tile.dart';
import 'package:real_estate/models/notifications/notification.dart'
    as my_notification;

class NotificationsListPage extends StatelessWidget {
  NotificationsListPage({super.key});
  final List<my_notification.Notification> notifications = [
    my_notification.Notification(
      id: 1,
      recipientId: 1,
      recipientEmail: 'hadialhamed.py@gmail.com',
      notificationType: my_notification.NotificationType.propertyFavorited,
      notificationTypeDisplay: 'Property Favorited',
      message: 'Someone finds your property special!',
      isRead: false,
      createdAt: DateTime.now(),
      relatedObjectData: '',
    ),
    my_notification.Notification(
      id: 2,
      recipientId: 2,
      recipientEmail: 'hadialhamed.py@gmail.com',
      notificationType: my_notification.NotificationType.propertyPriceChange,
      notificationTypeDisplay: 'Property Price Changed',
      message:
          'Property located at Damascus changed its price from 600\$ to 550\$',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      relatedObjectData: '',
    ),
    my_notification.Notification(
      id: 3,
      recipientId: 3,
      recipientEmail: 'hadialhamed.py@gmail.com',
      notificationType: my_notification.NotificationType.propertyRated,
      notificationTypeDisplay: 'Property Rated',
      message: 'Someone  rated your property with 4 stars!',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 32)),
      relatedObjectData: '',
    ),
    my_notification.Notification(
      id: 4,
      recipientId: 4,
      recipientEmail: 'hadialhamed.py@gmail.com',
      notificationType: my_notification.NotificationType.propertyStatus,
      notificationTypeDisplay: 'Property Status',
      message: 'a property you like has been back to the market!',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      relatedObjectData: '',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.black45
                      : const Color.fromARGB(133, 205, 175, 192),
                  primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ListView.builder(
            itemCount: 4,
            itemBuilder: (context, index) {
              return NotificationTile(
                notification: notifications[index],
              );
            },
          ),
        ],
      ),
    );
  }
}
