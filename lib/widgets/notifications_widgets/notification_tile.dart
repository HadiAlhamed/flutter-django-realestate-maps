import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/models/notifications/notification.dart'
    as my_notification;

class NotificationTile extends StatelessWidget {
  final my_notification.Notification notification;
  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed("/propertyDetails",
            arguments: {'propertyId': notification.relatedObjectData.id!});
      },
      child: Padding(
        // Outer margin for spacing between tiles
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16), // Inner padding
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withAlpha((0.05 * 255).round())
                    : Colors.white.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withAlpha((0.15 * 255).round()),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      handleNotificationIcon(context),
                      const SizedBox(width: 25),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.notificationTypeDisplay,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            DateFormat("dd MMM yyyy | hh:mm a")
                                .format(notification.createdAt),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? greyText
                                          : Colors.blueGrey,
                                    ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (!notification.isRead)
                        Icon(
                          Icons.fiber_new_sharp,
                          color: primaryColor,
                          size: 35,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    notification.message,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget handleNotificationIcon(BuildContext context) {
    Color iconColor = Colors.green;
    IconData iconData = Icons.price_change_outlined;

    //priceChange (green or red),
    //
    if (notification.notificationType ==
        my_notification.NotificationType.propertyPriceChange) {
      iconData = Icons.price_change_outlined;
      iconColor = Colors.green;
    } else if (notification.notificationType ==
        my_notification.NotificationType.propertyFavorited) {
      iconData = Icons.favorite;
      iconColor = primaryColor;
    } else if (notification.notificationType ==
        my_notification.NotificationType.propertyRated) {
      iconData = Icons.rate_review_rounded;
      iconColor = Colors.amber;
    } else {
      //propertyStatus
      iconData = Icons.notifications_active;
      iconColor = Colors.blue;
    }
    return CircleAvatar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color.fromARGB(255, 46, 44, 44)
          : const Color.fromARGB(255, 201, 180, 196),
      child: Icon(
        iconData,
        size: 30,
        color: iconColor,
      ),
    );
  }
}
