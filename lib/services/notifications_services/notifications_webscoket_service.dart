import 'dart:convert';

import 'package:get/get.dart';
import 'package:real_estate/controllers/notifications_controllers/notifications_controller.dart';
import 'package:real_estate/controllers/properties_controllers/property_details_controller.dart';
import 'package:real_estate/controllers/properties_controllers/property_controller.dart';
import 'package:real_estate/models/notifications/notification.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/auth_services/token_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationsWebscoketService {
  static final NotificationsWebscoketService _instance =
      NotificationsWebscoketService._internal();
  factory NotificationsWebscoketService() => _instance;

  NotificationsWebscoketService._internal();
  WebSocketChannel? _channel;
  final NotificationsController notificationsController =
      Get.find<NotificationsController>();
  final PropertyDetailsController pdController =
      Get.find<PropertyDetailsController>();
  final PropertyController pController = Get.find<PropertyController>();
  bool _connected = false;

  Future<void> connect() async {
    print(
        "connect() called from: ${StackTrace.current}"); // 🐞 For debugging origin

    String? accessToken = await TokenService.getAccessToken();
    if (accessToken == null) {
      print(
          "NotificationsWebscoketService :: NotificationsWebscoketService :: accessToken is null");
      return;
    }
    if (_connected) {
      print("NotificationsWebSocketService :: Already connected");
      return;
    }
    if (_channel != null) {
      print(
          "NotificationsWebscoketService :: NotificationsWebscoketService :: channel already connected");
      return;
    }
    final url = Uri.parse('${Api.wsUrl}/ws/notifications/?token=$accessToken');
    _channel = WebSocketChannel.connect(url);
    _connected = true;

    print("🌐 Connecting to WebSocket from notifications: $url");
    _channel!.stream.listen(
      (notification) {
        print('Received Notification WS message: $notification');
        _handleNotificationWebSocketMessage(jsonDecode(notification));
      },
      onDone: () {
        print('Notification WebSocket disconnected.');
        _connected = false;
        _channel = null;
      },
      onError: (error) {
        print('Notification WebSocket error: $error');
        _connected = false;
        _channel = null;
        // Handle errors, e.g., token expired, network issues
        // If token expired, prompt user to re-authenticate},
      },
    );
  }

  void disconnectNotificationWebSocket() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
      _connected = false;
      print('Notification WebSocket closed.');
    }
  }

  void _handleNotificationWebSocketMessage(Map<String, dynamic> data) {
    print("notifcation data : $data");
    String? type = data['type'];

    print("type : $type");
    switch (type) {
      case null:
        final newNotification = Notification.fromJson(data);
        //add it to the stream of the notificationController
        notificationsController.insertNewNotification(newNotification);
        pdController.updateFavoriteProperty(
          newNotification.relatedObjectData.id!,
          isActive: newNotification.relatedObjectData.isActive,
          newPrice: newNotification.relatedObjectData.price,
          newRating: newNotification.relatedObjectData.rating,
        );
        pController.updateProperty(
          newNotification.relatedObjectData.id!,
          isActive: newNotification.relatedObjectData.isActive,
          newPrice: newNotification.relatedObjectData.price,
          newRating: newNotification.relatedObjectData.rating,
        );
        break;
      case 'notification.unread_count_update':
        final newCount = data['count'] as int;
        notificationsController.setUnreadCount = newCount;
        //handle the update from the notificationController
        break;
      case 'pong': //ping pong ,
        print('Received pong from server.');
        break;

      default:
        print('Unknown Notification WebSocket message type: $type');
    }
  }
}
