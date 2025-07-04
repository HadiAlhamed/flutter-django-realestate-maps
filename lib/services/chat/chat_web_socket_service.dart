import 'dart:async';
import 'dart:convert';

import 'package:real_estate/services/auth_apis/auth_apis.dart';
import 'package:real_estate/services/auth_services/token_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatWebSocetService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageStreamController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get messagesStream =>
      _messageStreamController.stream;

  void connect({
    required String accessToken,
    required int conversationId,
  }) {
    final url =
        'ws://localhost:8001/ws/chat/$conversationId/?token=$accessToken';
    _channel = IOWebSocketChannel.connect(Uri.parse(url));

    _channel!.stream.listen(
      (data) {
        final message = json.decode(data);
        _messageStreamController.add(message);
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
      onDone: () {
        print("WebSocket closed.");
      },
    );
  }

  void sendMessage(Map<String, dynamic> message) {
    _channel?.sink.add(json.encode(message));
  }

  void close() {
    _channel?.sink.close();
  }
}
