import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint(
      'Background notification tap received: ${notificationResponse.payload}');
  // Add background logic here if needed
}

class NotificationsServices {
  //use singleton pattern

  static final NotificationsServices _instance =
      NotificationsServices._internal();
  factory NotificationsServices() => _instance;

  NotificationsServices._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("Notification clicked with payload: ${details.payload}");
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
      id.toString(),
      'General Notifications',
      channelDescription: 'For showing basic notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationsDetail,
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showMessagingStyleNotification() async {
    // Define the people in the conversation
    final Person me = Person(
      name: 'You',
      key: 'you',
    );

    final Person sarah = Person(
      name: 'Sarah',
      key: 'sarah',
    );

    // List of messages
    final styleInformation = MessagingStyleInformation(
      me, // yourself
      conversationTitle: 'Chat with Sarah',
      messages: [
        Message('Hey, are you free tonight?',
            DateTime.now().subtract(Duration(minutes: 3)), sarah),
        Message('Yes, I am. What’s up?',
            DateTime.now().subtract(Duration(minutes: 2)), me),
        Message('Wanna grab coffee?',
            DateTime.now().subtract(Duration(minutes: 1)), sarah),
      ],
    );

    final androidDetails = AndroidNotificationDetails(
      'chat_channel_id',
      'Chat Notifications',
      channelDescription: 'For messaging style chat notifications',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: styleInformation,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      1,
      'New messages from Sarah', // Fallback title
      'Hey, are you free tonight?', // Fallback body
      notificationDetails,
      payload: 'chat_sarah_1',
    );
  }
}
