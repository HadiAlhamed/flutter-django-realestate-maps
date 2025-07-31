import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:real_estate/models/notifications/notification.dart'
    as my_notification;
import 'package:real_estate/models/notifications/paginated_notifications.dart';
import 'package:real_estate/services/notifications_services/notifications_apis.dart';

class NotificationsController extends GetxController {
  RxList<my_notification.Notification> notifications =
      <my_notification.Notification>[].obs;
  RxBool isLoading = false.obs;
  String? nextPageUrl;

  void Function(my_notification.Notification)? onNotificationInserted;

  void setInsertCallback(Function(my_notification.Notification) callback) {
    onNotificationInserted = callback;
  }

  void changeIsLoading(bool value) {
    isLoading.value = value;
  }

  Future<List<my_notification.Notification>> getNotifications() async {
    changeIsLoading(true);
    PaginatedNotifications pNotifications =
        await NotificationsApis.getNotifications(url: nextPageUrl);

    nextPageUrl = pNotifications.nextUrl;

    // Only keep new ones
    final newItems = pNotifications.notifications
        .where(
          (n) => !notifications.any((existing) => existing.id == n.id),
        )
        .toList();

    notifications.addAll(newItems);
    changeIsLoading(false);

    return newItems;
  }

  void insertNewNotification(
    my_notification.Notification notif,
  ) {
    notifications.insert(0, notif); // Insert at top
    onNotificationInserted?.call(notif); // Notify widget to animate
  }

  bool hasMoreData() {
    return nextPageUrl != null;
  }

  void clear() {
    notifications.clear();
    nextPageUrl = null;
    isLoading.value = false;
  }
}
