import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_estate/models/message.dart';
import 'package:real_estate/services/auth_services/token_service.dart';
import 'package:real_estate/services/chat_services/chat_web_socket_service.dart';

class ChatController extends GetxController {
  final Map<int, ChatWebSocketService> _activeSockets = {};
  final Map<int, Stream<Map<String, dynamic>>> _messageStreams = {};
  Map<int, RxList<Message>> messages = {}; //userid , list of messages with him
  Map<int, RxInt> unreadCount =
      {}; //user id , number of unread messages from him
  Map<int, RxBool> isTyping =
      {}; //user id , is he typing or not, if not show last message
  Map<int, RxBool> isOtherUserOnline = {}; //user id , online or now
  Map<int, RxString> lastSeen = {}; //user id , his last seen
  //add last Seen
  Future<void> connectToChat({
    required int conversationId,
    required int currentUserId,
  }) async {
    if (_activeSockets.containsKey(conversationId)) return;

    String? accessToken = await TokenService.getAccessToken();
    if (accessToken == null) {
      print(
          "ChatController :: connectToChat :: ❌ Access token not found. User might be logged out.");
      return;
    }
    final socketService = ChatWebSocketService();
    socketService.connect(
      accessToken: accessToken,
      conversationId: conversationId,
    );
    _activeSockets[conversationId] = socketService;
    _messageStreams[conversationId] = socketService.messagesStream;
    //change what need to be changed
    _messageStreams[conversationId]!.listen(
      (data) {
        print("new data from chat stream : $data");
        final String? type = data['type'];
        if (type == null) {
          //incoming chat
          Message message = Message.fromJson(data);

          _getMessagesFor(conversationId).add(message);
          _getUnreadCountFor(conversationId).value += 1;
        } else if (type == "typing_status") {
          if (data['user_id'] != currentUserId) {
            _getIsTypingFor(conversationId).value = data['is_typing'];
          }
        } else if (type == 'user_status_update') {
          if (data['user_id'] != currentUserId) {
            _getIsOtherUserOnlineFor(conversationId).value = data['is_online'];
            if (data['last_seen'] != null) {
              handleLastSeen(data, conversationId);
            }
          }
        } else if (type == 'messages_read_confirmation') {
          if (data['reader_user_id'] == currentUserId) {
            _markMessagesAsRead(data['message_ids'], conversationId);
          }
        }
      },
      onError: (error) {
        print("WebSocket error: $error");
      },
      onDone: () {
        print("WebSocket closed for conversation $conversationId");
      },
    );
    print("chatController :: connectToChat :: success!!");
  }

  void _markMessagesAsRead(List ids, int conversationId) {
    messages[conversationId]!.value = messages[conversationId]!.map((msg) {
      if (ids.contains(msg.id)) {
        msg.isRead = true;
      }
      return msg;
    }).toList();
    unreadCount[conversationId]!.value = 0;
  }

  void sendTextMessage(String content, int conversationId) {
    _activeSockets[conversationId]!.sendMessage({
      'type': 'chat_message',
      'content': content,
      'file_url': null,
      'message_type': 'text',
    });
  }

  void sendTypingStatus(bool isTyping, int conversationId) {
    _activeSockets[conversationId]!.sendMessage({
      'type': 'typing',
      'is_typing': isTyping,
    });
  }

  void markAsRead(List<String> messageIds, int conversationId) {
    _activeSockets[conversationId]!.sendMessage({
      "type": "mark_as_read",
      "message_ids": messageIds,
    });
  }

  RxList<Message> _getMessagesFor(int conversationId) {
    return messages.putIfAbsent(conversationId, () => RxList<Message>());
  }

  RxInt _getUnreadCountFor(int conversationId) {
    return unreadCount.putIfAbsent(conversationId, () => RxInt(0));
  }

  RxBool _getIsTypingFor(int conversationId) {
    return isTyping.putIfAbsent(conversationId, () => RxBool(false));
  }

  RxBool _getIsOtherUserOnlineFor(int conversationId) {
    return isOtherUserOnline.putIfAbsent(conversationId, () => RxBool(false));
  }

  void clear() {
    for (int key in _activeSockets.keys) {
      _activeSockets[key]!.close();
    }
    _activeSockets.clear();
    _messageStreams.clear();
    messages.clear();
    unreadCount.clear();
    isTyping.clear();
    isOtherUserOnline.clear();
    lastSeen.clear();
  }

  @override
  void onClose() {
    for (int key in _activeSockets.keys) {
      _activeSockets[key]!.close();
    }

    _activeSockets.clear();
    _messageStreams.clear();
    messages.clear();
    unreadCount.clear();
    isTyping.clear();
    isOtherUserOnline.clear();
    lastSeen.clear();
    super.onClose();
  }

  void handleLastSeen(Map<String, dynamic> data, int conversationId) {
    DateTime lastSeenDate = data['last_seen'];
    DateTime now = DateTime.now();
    String wantedDate = "";
    final Duration sinceLastSeen = now.difference(lastSeenDate);
    wantedDate = "at ${DateFormat('hh:mm a').format(lastSeenDate)}";
    if (lastSeenDate.day == now.subtract(Duration(days: 1)).day) {
      wantedDate = "yesterday at $wantedDate";
    } else if (sinceLastSeen.inDays > 1) {
      wantedDate = "at ${DateFormat('hh:mm a dd-MM-yy').format(lastSeenDate)}";
    }
    _getLastSeenFor(conversationId).value = "last seen $wantedDate";
  }

  RxString _getLastSeenFor(int conversationId) {
    return lastSeen.putIfAbsent(
        conversationId, () => RxString("last seen recently"));
  }
}
