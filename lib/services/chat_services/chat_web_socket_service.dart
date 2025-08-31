import 'dart:async';
import 'dart:convert';

import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/auth_services/auth_apis.dart';
import 'package:real_estate/services/auth_services/token_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatWebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>> _messageStreamController =
      StreamController();

  Stream<Map<String, dynamic>> get messagesStream =>
      _messageStreamController.stream;
  StreamSubscription? _webSocketSubscription;
  bool _isConnectingOrConnected = false;
  Future<void> connect({
    required String accessToken,
    required int conversationId,
  }) async {
    if (_isConnectingOrConnected || _channel != null) {
      print(
          "⚠️ Already connecting or connected. Skipping redundant connect call.");
      return;
    }

    _isConnectingOrConnected = true;

    try {
      // Clean up previous connection if any
      await _webSocketSubscription?.cancel();
      await _channel?.sink.close();
      _channel = null;

      // Recreate stream controller only if needed
      if (_messageStreamController.isClosed) {
        _messageStreamController = StreamController();
      }

      final url = '${Api.wsUrl}/ws/chat/$conversationId/?token=$accessToken';
      print("🌐 Connecting to WebSocket: $url");

      _channel = IOWebSocketChannel.connect(Uri.parse(url));

      _webSocketSubscription = _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data);
            print("!!!Recieved data from websocket $message");
            _messageStreamController.add(message);
          } catch (e) {
            print("❌ Error decoding WebSocket data: $e");
          }
        },
        onError: (error) async {
          print("⚠️ WebSocket error: $error");

          if (error.toString().contains("401") ||
              error.toString().contains("HandshakeException")) {
            print("🔄 Attempting token refresh...");
            bool refreshed = await AuthApis.refreshToken();
            if (refreshed) {
              await connect(
                accessToken: (await TokenService.getAccessToken())!,
                conversationId: conversationId,
              );
            }
          } else {
            scheduleReconnect(conversationId);
          }
        },
        onDone: () async {
          print("🔌 WebSocket closed unexpectedly.");
          final ioChannel = _channel as IOWebSocketChannel?;
          print("🛑 Close code: ${ioChannel?.closeCode}");
          print("📄 Close reason: ${ioChannel?.closeReason}");

          await _webSocketSubscription?.cancel();
          _webSocketSubscription = null;
          _channel = null;
          scheduleReconnect(conversationId);
        },
        cancelOnError: true,
      );
    } catch (e) {
      print("🚨 WebSocket connection failed: $e");
    } finally {
      _isConnectingOrConnected = false;
    }
  }

  void scheduleReconnect(int conversationId) {
    Future.delayed(Duration(seconds: 5), () async {
      print("🔁 Trying to reconnect...");
      final newToken = await TokenService.getAccessToken();
      if (newToken != null) {
        await connect(
          accessToken: newToken,
          conversationId: conversationId,
        );
      } else {
        print("🚫 Can't reconnect — no valid token.");
      }
    });
  }

  Future<void> sendMessage(
      String? content, String? fileUrl, String messageType) async {
    if (_channel != null) {
      print("WebSocket is connected");
    } else {
      print("WebSocket is null (not connected)");
    }
    print("webSocket :: sendMessage :: $messageType");
    String jsonMessage = jsonEncode({
      "type": "chat_message",
      "file_url": fileUrl,
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
    //cancel stream subscription and make it null
    //close websocket channel and make it null
    //close stream controller
    _webSocketSubscription?.cancel();
    _webSocketSubscription = null;

    _channel?.sink.close();
    _channel = null;

    if (!_messageStreamController.isClosed) {
      _messageStreamController.close();
    }

    _isConnectingOrConnected = false;
  }

  void close() {
    _channel?.sink.close();
    _webSocketSubscription?.cancel();
    _isConnectingOrConnected = false;

    _messageStreamController.close();
  }
}
