import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint(
      'Background notification tap received: ${notificationResponse.payload}');
  // Add background logic here if needed
  NotificationsServices().tappedBackgroundPayload =
      notificationResponse.payload;
}

class NotificationsServices {
  //use singleton pattern

  static final NotificationsServices _instance =
      NotificationsServices._internal();
  factory NotificationsServices() => _instance;

  NotificationsServices._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Map<String, List<Message>> _messageHistory =
      HashMap(); // senderId -> messages
  final Map<String, Person> _people = {}; // senderId -> Person
  final Person _me = const Person(name: "You", key: "me");
  void Function(String payload)? _onForegroundNotificationTap;
  String? tappedBackgroundPayload; //for background handling

  void registerForegroundTapHandler(void Function(String payload) handler) {
    _onForegroundNotificationTap = handler;
  }

  Future<void> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> init() async {
    await requestPermissions();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      onDidReceiveNotificationResponse: (details) {
        // Get.snackbar("Tapped", "Notification payload: ${details.payload}");

        _onForegroundNotificationTap?.call(details.payload!);
      },
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidNotificationsDetail = AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      channelDescription: 'For showing basic notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_stat_aqari_logo_primary_towers', // ← no file extension
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationsDetail,
    );
    print("trying to show notificaition : $id , $title , $body");
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showMessageNotification({
    required String senderId,
    required String senderName,
    required String messageText,
    String? conversationTitle,
    String? payload,
  }) async {
    // Register the sender if not already
    _people.putIfAbsent(
        senderId, () => Person(name: senderName, key: senderId));

    // Add new message to history
    _messageHistory.putIfAbsent(senderId, () => []);
    _messageHistory[senderId]!.add(
      Message(messageText, DateTime.now(), _people[senderId]!),
    );

    final style = MessagingStyleInformation(
      _me,
      conversationTitle: conversationTitle ?? senderName,
      messages: _messageHistory[senderId]!,
    );

    final androidDetails = AndroidNotificationDetails(
      'chat_channel_id',
      'Chat Notifications',
      channelDescription: 'Used for chat messages',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: style,
      icon: 'ic_stat_aqari_logo_primary_towers', // ← no file extension
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    // Use a consistent ID per sender
    final notificationId = senderId.hashCode;

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      senderName,
      messageText,
      notificationDetails,
      payload: payload,
    );
  }

  void clearMessageHistoryFor(String senderId) {
    _messageHistory.putIfAbsent(senderId, () => []);
    _messageHistory[senderId]!.clear();
    final notificationId = senderId.hashCode;
    flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}
