import 'dart:async';
import 'dart:convert';

import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/auth_apis/auth_apis.dart';
import 'package:real_estate/services/auth_services/token_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatWebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageStreamController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get messagesStream =>
      _messageStreamController.stream;
  StreamSubscription? _webSocketSubscription;

  Future<void> connect({
    required String accessToken,
    required int conversationId,
  }) async {
    if (_channel != null) {
      print("🔁 Already connected, closing old socket before reconnecting.");
      await _webSocketSubscription?.cancel();
      _channel?.sink.close(); // Cleanly close the channel
      _channel = null;
    }
    final url = '${Api.wsUrl}/ws/chat/$conversationId/?token=$accessToken';
    print("websocket connection url : $url");
    _channel = IOWebSocketChannel.connect(Uri.parse(url));
    _webSocketSubscription = _channel!.stream.listen(
      (data) {
        try {
          final message = jsonDecode(data);
          _messageStreamController.add(message);
          print("!!!!!!!!Received from WebSocket: $data ##########");
        } catch (e) {
          print("Unexpected Error : webSocket listening : $e");
        }
      },
      onError: (error) async {
        print("WebSocket error: $error");

        if (error.toString().contains("401") ||
            error.toString().contains("HandshakeException")) {
          print("⚠️ Possibly unauthorized. Attempting token refresh...");

          bool refreshed = await AuthApis.refreshToken();

          if (refreshed) {
            connect(
              // Reconnect with new token
              accessToken: (await TokenService.getAccessToken())!,
              conversationId: conversationId,
            );
          } else {
            print("🚫 Token refresh failed. Log user out.");
            // Call logout or show session expired UI
          }
        }
      },
      onDone: () async {
        print("WebSocket closed.");
        final ioChannel = _channel as IOWebSocketChannel?;
        final closeCode = ioChannel?.closeCode;
        final closeReason = ioChannel?.closeReason;

        print("🛑 Close code: $closeCode");
        print("📄 Close reason: $closeReason");

        _webSocketSubscription!.cancel();
      },
      cancelOnError: true,
    );
  }

  Future<void> sendTextMessage(String content, String messageType) async {
    if (_channel != null) {
      print("WebSocket is connected");
    } else {
      print("WebSocket is null (not connected)");
    }
    final jsonMessage = jsonEncode({
      "type": "chat_message",
      "file_url": null,
      "content": content,
      "message_type": messageType
    });
    print("📤 FINAL message sent to WebSocket:\n$jsonMessage");

    print("🧪 Type of jsonMessage: ${jsonMessage.runtimeType}");

    _channel?.sink.add(jsonMessage);

    if (_channel != null) {
      print("WebSocket is connected");
    } else {
      print("WebSocket is null (not connected)");
    }
  }

  Future<void> markAsRead(List<String> messageIds) async {
    if (_channel != null) {
      print("WebSocket is connected");
    } else {
      print("WebSocket is null (not connected)");
    }
    final jsonMessage = jsonEncode(
      {
        "type": "mark_as_read",
        "message_ids": messageIds,
      },
    );
    print("📤 markAsRead message sent to WebSocket:\n$jsonMessage");

    print("🧪 Type of jsonMessage: ${jsonMessage.runtimeType}");

    _channel?.sink.add(jsonMessage);

    if (_channel != null) {
      print("WebSocket is connected");
    } else {
      print("WebSocket is null (not connected)");
    }
  }

  Future<void> sendIsTyping(bool isTyping) async {
    if (_channel != null) {
      print("WebSocket is connected");
    } else {
      print("WebSocket is null (not connected)");
    }
    final jsonMessage = jsonEncode(
      {"type": "typing", 'is_typing': isTyping},
    );
    print("📤 sendIsTyping message sent to WebSocket:\n$jsonMessage");

    print("🧪 Type of jsonMessage: ${jsonMessage.runtimeType}");

    _channel?.sink.add(jsonMessage);
  }

  void dispose() {
    _webSocketSubscription?.cancel();
    _messageStreamController.close();
    _channel?.sink.close();
  }

  void close() {
    _channel?.sink.close();
    // _messageStreamController.close();
  }
}
