import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_estate/models/message.dart';
import 'package:real_estate/services/chat/chat_web_socket_service.dart';

class ChatController extends GetxController {
  final ChatWebSocetService _socketService = ChatWebSocetService();
  RxList<Message> messages = <Message>[].obs;
  RxInt unreadCount = 0.obs;
  RxBool isTyping = false.obs;
  RxBool isOtherUserOnline = false.obs;
  RxString lastSeen = "last seen recently".obs;
  //add last Seen
  void connectToChat({
    required String accessToken,
    required int conversationId,
    required int currentUserId,
  }) {
    _socketService.connect(
      accessToken: accessToken,
      conversationId: conversationId,
    );

    _socketService.messagesStream.listen(
      (data) {
        print("new data from chat stream : $data");
        final String? type = data['type'];
        if (type == null) {
          //incoming chat
          messages.add(Message.fromJson(data));
          unreadCount.value += 1;
        } else if (type == "typing_status") {
          if (data['user_id'] != currentUserId) {
            isTyping.value = data['is_typing'];
          }
        } else if (type == 'user_status_update') {
          if (data['user_id'] != currentUserId) {
            isOtherUserOnline.value = data['is_online'];
            if (data['last_seen'] != null) {
              handleLastSeen(data);
            }
          }
        } else if (type == 'messages_read_confirmation') {
          if (data['reader_user_id'] == currentUserId) {
            _markMessagesAsRead(data['message_ids']);
          }
        }
      },
      onError: (error) {},
      onDone: () {},
    );
  }

  void _markMessagesAsRead(List ids) {
    messages.value = messages.map((msg) {
      if (ids.contains(msg.id)) {
        msg.isRead = true;
      }
      return msg;
    }).toList();
    unreadCount.value = 0;
  }

  void sendTextMessage(String content) {
    _socketService.sendMessage({
      'type': 'chat_message',
      'content': content,
      'file_url': null,
      'message_type': 'text',
    });
  }

  void sendTypingStatus(bool isTyping) {
    _socketService.sendMessage({
      'type': 'typing',
      'is_typing': isTyping,
    });
  }
  void markAsRead(List<String> messageIds) {
    _socketService.sendMessage({
      "type": "mark_as_read",
      "message_ids": messageIds,
    });
  }
  @override
  void onClose() {
    _socketService.close();
    super.onClose();
  }

  void handleLastSeen(Map<String, dynamic> data) {
    DateTime lastSeenDate = data['last_seen'];
    DateTime now = DateTime.now();
    String wantedDate = "";
    final Duration sinceLastSeen = now.difference(lastSeenDate);
    wantedDate = "at ${DateFormat('hh:mm a').format(lastSeenDate)}";
    if (sinceLastSeen.inDays == 1) {
      wantedDate = "yesterday at$wantedDate";
    } else if (sinceLastSeen.inDays > 1) {
      wantedDate = "at ${DateFormat('hh:mm a dd-MM-yy').format(lastSeenDate)}";
    }
    lastSeen.value = "last seen $wantedDate";
  }
}
