import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_estate/models/conversation.dart';
import 'package:real_estate/models/message.dart';
import 'package:real_estate/services/api.dart';
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
  Map<int, RxString> lastMessageFor = {};
  Map<int, RxString> lastMessageTime = {};
  List<Conversation> chats = [];
  int currentConversationId = 0;
  int anyConversationId = 0;
  set anyConvId(int conversationId) => anyConversationId = conversationId;
  int get anyConvId => anyConversationId;
  set currentConvId(int conversationId) =>
      currentConversationId = conversationId;
  int get currentConvId => currentConversationId;
  //add last Seen
  bool isConnected = false;
  bool fetchedAll = false;
  RxBool loadingChats = RxBool(false);
  void changeLoadingChats(bool value) {
    loadingChats.value = value;
  }

  void add(Conversation conversation) {
    chats.add(conversation);
    getUnreadCountFor(conversation.id).value = conversation.unreadCount;
    getIsTypingFor(conversation.id).value = false;
    getIsOtherUserOnlineFor(conversation.id).value =
        conversation.otherUserIsOnline ?? false;
    handleLastSeen({'last_seen': conversation.otherUserLastSeen.toString()},
        conversation.id);

    isConnected = true;
    anyConvId = conversation.id;
    connectToChat(
        conversationId: conversation.id,
        currentUserId: Api.box.read('currentUserId'));
  }

  void changeIsConnected(bool value) {
    isConnected = value;
  }

  Future<void> connectToChat({
    required int conversationId,
    required int currentUserId,
  }) async {
    if (_activeSockets.containsKey(conversationId))
      return; //check if this could be a bug
    print("chatController :: connectToChat : conversationId $conversationId");
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
    //change what need to be changed
    if (_messageStreams.containsKey(conversationId)) {
      print("Already listening to stream for $conversationId");
      return;
    }
    _messageStreams[conversationId] = socketService.messagesStream;

    _messageStreams[conversationId]!.listen(
      (data) {
        print("new data from chat stream : $data");
        final String? type = data['type'];
        print("type : $type");
        if (type == null) {
          //incoming chat

          Message message = Message.fromJson(data);
          if (message.fileUrl == null) {
            getLastMessageFor(conversationId).value = message.content!;
          } else {
            getLastMessageFor(conversationId).value = "File";
          }
          getLastMessageTimeFor(conversationId).value =
              handleLastMessageTime(message.createdAt);
          getMessagesFor(conversationId).add(message);
          if (currentConversationId != conversationId) {
            getUnreadCountFor(conversationId).value += 1;
          }
        } else if (type == "typing_status") {
          if (data['user_id'] != currentUserId) {
            getIsTypingFor(conversationId).value = data['is_typing'];
          }
        } else if (type == 'user_status_update') {
          if (data['user_id'] != currentUserId) {
            getIsOtherUserOnlineFor(conversationId).value = data['is_online'];
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
    print("trying to send text message for conversation $conversationId");
    _activeSockets[conversationId]!.sendMessage(content, "text");
    print("end!!");
  }

  // void sendTypingStatus(bool isTyping, int conversationId) {
  //   _activeSockets[conversationId]!.sendMessage({
  //     'type': 'typing',
  //     'is_typing': isTyping,
  //   });
  // }

  // void markAsRead(List<String> messageIds, int conversationId) {
  //   _activeSockets[conversationId]!.sendMessage({
  //     "type": "mark_as_read",
  //     "message_ids": messageIds,
  //   });
  // }

  RxList<Message> getMessagesFor(int conversationId) {
    return messages.putIfAbsent(conversationId, () => RxList<Message>());
  }

  RxInt getUnreadCountFor(int conversationId) {
    return unreadCount.putIfAbsent(conversationId, () => RxInt(0));
  }

  RxBool getIsTypingFor(int conversationId) {
    return isTyping.putIfAbsent(conversationId, () => RxBool(false));
  }

  RxBool getIsOtherUserOnlineFor(int conversationId) {
    return isOtherUserOnline.putIfAbsent(conversationId, () => RxBool(false));
  }

  void disconnect({int? exceptId, int? onlyThis}) {
    print("anyConvId $anyConversationId");
    print("onlyThis : $onlyThis");
    if (onlyThis != null) {
      if (onlyThis == anyConvId) return; //this is the only active conv
      _activeSockets[onlyThis]?.close();
      _activeSockets.remove(onlyThis);

      return;
    }
    print("chat controller :: disconnect except : ${exceptId.toString()}");
    List<int> activeSocketsKeys = _activeSockets.keys.toList();
    for (int key in activeSocketsKeys) {
      if (exceptId != null && key == exceptId) continue;

      _activeSockets[key]?.close();
      _activeSockets.remove(key);
    }
  }

  void clear({bool? leaveConvIds}) {
    print("clearing chat Controller");
    for (int key in _activeSockets.keys) {
      print("closing sockets for conversation : $key");
      _activeSockets[key]!.close();
    }
    _activeSockets.clear();
    _messageStreams.clear();
    messages.clear();
    unreadCount.clear();
    isTyping.clear();
    isOtherUserOnline.clear();
    lastSeen.clear();
    isConnected = false;
    fetchedAll = false;
    leaveConvIds ??= false;
    chats.clear();

    if (!leaveConvIds) {
      currentConversationId = 0;
      anyConversationId = 0;
    }
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

  String handleLastMessageTime(DateTime lastMessageTime) {
    DateTime now = DateTime.now();
    String wantedDate = "";
    wantedDate = DateFormat('hh:mm a').format(lastMessageTime);
    if (lastMessageTime.day == now.day) {
    } else if (lastMessageTime.day == now.subtract(Duration(days: 1)).day) {
      wantedDate = "yesterday $wantedDate";
    } else {
      wantedDate = DateFormat('dd/MM/yy').format(lastMessageTime);
    }
    return wantedDate;
  }

  void handleLastSeen(Map<String, dynamic> data, int conversationId) {
    DateTime lastSeenDate = DateTime.parse(data['last_seen']);
    DateTime now = DateTime.now();
    String wantedDate = "";
    wantedDate = "at ${DateFormat('hh:mm a').format(lastSeenDate)}";
    if (lastSeenDate.day == now.day) {
    } else if (lastSeenDate.day == now.subtract(Duration(days: 1)).day) {
      wantedDate = "yesterday at $wantedDate";
    } else {
      wantedDate = "at ${DateFormat('hh:mm a dd-MM-yy').format(lastSeenDate)}";
    }
    _getLastSeenFor(conversationId).value = "last seen $wantedDate";
  }

  RxString _getLastSeenFor(int conversationId) {
    return lastSeen.putIfAbsent(
        conversationId, () => RxString("last seen recently"));
  }

  RxString getLastMessageTimeFor(int conversationId) {
    return lastMessageTime.putIfAbsent(conversationId, () => RxString(""));
  }

  RxString getLastMessageFor(int conversationId) {
    return lastMessageFor.putIfAbsent(conversationId, () => RxString(""));
  }
}
