import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:real_estate/models/conversations/conversation.dart';
import 'package:real_estate/models/conversations/message.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/auth_services/token_service.dart';
import 'package:real_estate/services/chat_services/chat_web_socket_service.dart';
import 'package:real_estate/services/notifications_services/notifications_apis.dart';
import 'package:real_estate/services/notifications_services/notifications_services.dart';

class ChatController extends GetxController {
  final notificationHandler = NotificationsServices();
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
  Map<int, bool> needFirstFetch = {};
  RxList<Conversation> chats = <Conversation>[].obs;
  int currentConversationId = -1;
  int anyConversationId = -1;
  RxInt totalUnreadCount = RxInt(-1);
  bool isBackground = false;
  void changeIsBackground(bool value) {
    isBackground = value;
  }

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

  void changeTotalUnreadCount(int value) {
    totalUnreadCount.value = value;
  }

  Future<void> add(Conversation conversation) async {
    print("adding conversation : $conversation\n");

    chats.add(conversation);

    getUnreadCountFor(conversation.id).value = conversation.unreadCount;
    getIsTypingFor(conversation.id).value = false;
    getIsOtherUserOnlineFor(conversation.otherUserId).value =
        conversation.otherUserIsOnline ?? false;
    handleLastSeen({'last_seen': conversation.otherUserLastSeen.toString()},
        conversation.otherUserId);
    getLastMessageFor(conversation.id).value =
        conversation.lastMessage ?? "null";
    getLastMessageTimeFor(conversation.id).value =
        handleLastMessageTime(conversation.updatedAt);
    if (anyConversationId == -1) anyConversationId = conversation.id;
    if (!isConnected) {
      await connectToChat(
          conversationId: conversation.id,
          currentUserId: Api.box.read('currentUserId'));
    }
    isConnected = true;
    return;
  }

  void changeIsConnected(bool value) {
    isConnected = value;
  }

  Future<void> connectToChat({
    required int conversationId,
    required int currentUserId,
  }) async {
    if (conversationId == -1) {
      debugPrint(
          "chatController :: connectToChat :: ERROR :: cannot have a conversationId equals to -1!!");
      return;
    }
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
    _messageStreams[conversationId] = socketService.messagesStream;

    if (_messageStreams[conversationId] != null) {
      _messageStreams[conversationId]!.listen(
        (data) {
          print(
              "new data from chat stream for conversation : $conversationId : $data");
          final String? type = data['type'];
          print("type : $type");
          if (type == null) {
            //incoming chat
            //conversation of this message should be on top
            handleIncomingMessage(data, conversationId);
          } else if (type == "typing_status") {
            int userId = data['user_id'] is String
                ? int.parse(data['user_id'])
                : data['user_id'];
            if (userId != currentUserId) {
              getIsTypingFor(userId).value = data['is_typing'];
            }
          } else if (type == 'user_status_update') {
            int userId = data['user_id'] is String
                ? int.parse(data['user_id'])
                : data['user_id'];
            if (userId != currentUserId) {
              getIsOtherUserOnlineFor(userId).value = data['is_online'];
              //change conversationId to userId
              //same for isTyping
              if (data['last_seen'] != null) {
                handleLastSeen(data, userId);
              }
            }
          } else if (type == 'messages_read_confirmation') {
            if (data['reader_user_id'] != currentUserId) {
              // print(data['message_ids']);
              print(data['message_ids'].runtimeType);

              List<String> messageIds = (data['message_ids'] as List)
                  .map((id) => id.toString())
                  .toList();
              print("messageIds : $messageIds");
              _markMessagesAsRead(messageIds, conversationId);
            }
          } else if (type == 'conversation_list_update') {
            print("chat controller : conversation list update message:");
            Message lastMessageData =
                Message.fromJson(data['last_message_data']);
            bool isNew = data['is_new_conversation'];

            Conversation conversation = Conversation(
              id: data['conversation_id'] is String
                  ? int.parse(data['conversation_id'])
                  : data['conversation_id'],
              otherUserId: data['other_participant_details']['id'] is String
                  ? int.parse(data['other_participant_details']['id'])
                  : data['other_participant_details']['id'],
              otherUserFirstName: data['other_participant_details']
                  ['first_name'],
              otherUserLastName: data['other_participant_details']['last_name'],
              unreadCount: data['unread_count_for_this_conversation'],
              lastMessage: lastMessageData.content,
              createdAt: DateTime.parse(data['created_at']).toLocal(),
              updatedAt: DateTime.parse(data['updated_at']).toLocal(),
              otherUserIsOnline: data['other_participant_details']['is_online'],
              otherUserLastSeen: DateTime.parse(
                  data['other_participant_details']['last_seen']),
              otherUserPhotoUrl: data['other_participant_details']['photo_url'],
            );
            debugPrint(
              "HI conversationId : $conversationId , anyConversationId : $anyConversationId",
            );
            if (conversationId == anyConversationId) {
              //so that we handle it once
              handleConversationListUpdate(
                conversation: conversation,
                isNew: isNew,
                lastMessageData: lastMessageData,
              );
            }
          } else if (type == 'typing_status_list_update') {
            int userId = data['user_id'] is String
                ? int.parse(data['user_id'])
                : data['user_id'];
            getIsTypingFor(userId).value = data['is_typing'] as bool;
          } else if (type == 'total_unread_chat_count') {
            changeTotalUnreadCount(data['count'] as int);
          }
        },
        onError: (error) {
          print("WebSocket error: $error");
        },
        onDone: () {
          print("WebSocket closed for conversation $conversationId");
          print(
              "we will schdule a reconnect if = anyConversationId ($anyConversationId)");
          if (conversationId == anyConversationId &&
              _activeSockets[conversationId] != null) {
            _activeSockets[conversationId]!.scheduleReconnect(conversationId);
          }
        },
      );
    }
    print("chatController :: connectToChat :: success!!");
  }

  void handleIncomingMessage(Map<String, dynamic> data, int conversationId) {
    Message message = Message.fromJson(data);
    if (message.senderId != Api.box.read('currentUserId') &&
        currentConversationId == conversationId) {
      markAsRead([message.id.toString()], conversationId);
    }
    // getMessagesFor(conversationId).add(message);
  }

  void handleConversationListUpdate({
    required Conversation conversation,
    required Message lastMessageData,
    required bool isNew,
  }) {
    int index = chats.indexWhere((conv) {
      return conversation.id == conv.id;
    });
    if (index != -1 && lastMessageData.id != chats[index].lastMessageId) {
      if (index != 0) {
        final moved = chats.removeAt(index);
        chats.insert(0, moved);
      }
    } else if (index == -1) {
      chats.insert(0, conversation);
      index = 0;
    }
    if (lastMessageData.fileUrl == null) {
      getLastMessageFor(conversation.id).value = lastMessageData.content!;
    } else {
      getLastMessageFor(conversation.id).value = "null";
    }
    getLastMessageTimeFor(conversation.id).value =
        handleLastMessageTime(lastMessageData.createdAt);

    //update unread count :
    getUnreadCountFor(conversation.id).value = conversation.unreadCount;
    //show a notification that someone has sent the user a message
    if (!lastMessageData.isRead &&
        lastMessageData.senderId != Api.box.read("currentUserId")) {
      //isRead is it enough?
      getMessagesFor(conversation.id).add(lastMessageData);
    }
    if (!lastMessageData.isRead &&
        lastMessageData.senderId != Api.box.read("currentUserId") &&
        (isBackground || currentConversationId != conversation.id)) {
      notificationHandler.showMessageNotification(
        messageText: lastMessageData.content ?? "File",
        senderId: (conversation.id).toString(),
        senderName:
            "${lastMessageData.senderFirstName} ${lastMessageData.senderLastName}",
        payload: jsonEncode({
          'type': 'message',
          'conversationId': conversation.id,
          'index': index,
        }),
      );
    }
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    notificationHandler.registerForegroundTapHandler(onTapForeground);
    // Post-frame to ensure Get.currentRoute is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? backgroundPayload =
          notificationHandler.tappedBackgroundPayload;
      if (backgroundPayload != null) {
        onTapForeground(backgroundPayload);
        notificationHandler.tappedBackgroundPayload = null;
      }
    });
  }

  void onTapForeground(String payload) async {
    //use payload to determine type of notificaiton : message or regular property notification
    Map<String, dynamic> payloadData = jsonDecode(payload);

    if (payloadData['type'] == 'property') {
      int propertyId = payloadData['propertyId'];
      int notifId =
          payloadData['notificationId']; //we need to make isRead = true
      if (Get.currentRoute == '/propertyDetails') {
        Get.back(); // pop current details
        await Future.delayed(
            Duration(milliseconds: 100)); // allow stack to clear
      }
      await NotificationsApis.markOneRead(notifId);
      Get.toNamed(
        '/propertyDetails',
        arguments: {
          'propertyId': propertyId,
        },
      );
    } else {
      //type = message
      while (Get.currentRoute == '/chatPage') {
        debugPrint("currentRoute : ${Get.currentRoute}");
        Get.back();
      }
      await Future.delayed(const Duration(milliseconds: 100));
      debugPrint(
          "onTapForegroud :: chatController.currentConversationId : $currentConversationId"); //should be -1 when currentRoute was /chatpage
      int conversationId = payloadData['conversationId'];
      int index = payloadData['index'];

      currentConversationId = conversationId;

      Get.toNamed('/chatPage', arguments: {
        'index': index,
        'conversationId': conversationId,
      });
    }
  }

  void _markMessagesAsRead(List<String> ids, int conversationId) {
    print("Hi from _markMessagesAsRead");
    messages[conversationId]!.value = messages[conversationId]!.map((msg) {
      if (ids.contains((msg.id).toString())) {
        msg.isRead = true;
      }
      return msg;
    }).toList();
    unreadCount[conversationId]!.value = 0;
  }

  void sendMessage(
      {String? content, String? fileUrl, required int conversationId}) {
    print("trying to send text message for conversation $conversationId");
    if (content != null) {
      _activeSockets[conversationId]?.sendMessage(
        content,
        fileUrl,
        "text",
      );
    } else if (fileUrl != null) {
      String messageType =
          path.extension(fileUrl).toLowerCase() == '.pdf' ? 'pdf' : 'image';
      _activeSockets[conversationId]?.sendMessage(
        content,
        fileUrl,
        messageType,
      );
      //messageType either image or pdf , you have to choose
    } else {
      print(
          "chatController :: sendMessage :: both content and fileUrl are null!!");
    }
    print("end!!");
  }

  void sendTypingStatus(bool isTyping, int conversationId) {
    if (_activeSockets[conversationId] != null) {
      _activeSockets[conversationId]!.sendIsTyping(isTyping);
    }
  }

  Future<void> markAsRead(List<String> messageIds, int conversationId) async {
    if (_activeSockets[conversationId] != null) {
      _activeSockets[conversationId]!.markAsRead(messageIds);
    }
  }

  RxList<Message> getMessagesFor(int conversationId) {
    return messages.putIfAbsent(conversationId, () => RxList<Message>());
  }

  RxInt getUnreadCountFor(int conversationId) {
    return unreadCount.putIfAbsent(conversationId, () => RxInt(0));
  }

  RxBool getIsTypingFor(int conversationId) {
    return isTyping.putIfAbsent(conversationId, () => RxBool(false));
  }

  RxBool getIsOtherUserOnlineFor(int userId) {
    return isOtherUserOnline.putIfAbsent(userId, () => RxBool(false));
  }

  bool getNeedFirstFetch(int conversationId) {
    return needFirstFetch.putIfAbsent(conversationId, () => true);
  }

  void disconnect({int? exceptId, int? onlyThis}) {
    print("disconnect called");

    if (onlyThis != null) {
      if (onlyThis == anyConvId) return;

      _activeSockets[onlyThis]?.dispose(); // ✅ proper clean-up
      _activeSockets.remove(onlyThis);
      _messageStreams.remove(onlyThis); // ✅ remove stream reference
      return;
    }

    for (int key in _activeSockets.keys.toList()) {
      if (exceptId != null && key == exceptId) continue;

      _activeSockets[key]?.dispose();
      _activeSockets.remove(key);
      _messageStreams.remove(key); // ✅ remove stream reference
      //should i delete messages too ?
    }
  }

  void clear({bool? leaveConvIds}) {
    print("clearing chat Controller");
    disconnect();
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
    needFirstFetch.clear();
    if (!leaveConvIds) {
      currentConversationId = -1;
      anyConversationId = -1;
    }
  }

  void clearMessageHistoryFor(int conversationId) {
    notificationHandler.clearMessageHistoryFor(conversationId.toString());
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }

  String handleLastMessageTime(DateTime? lastMessageTime) {
    if (lastMessageTime == null) return "";
    lastMessageTime = lastMessageTime.toLocal();
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

  void handleLastSeen(Map<String, dynamic> data, int userId) {
    DateTime lastSeenDate = DateTime.parse(data['last_seen']).toLocal();

    DateTime now = DateTime.now();
    String wantedDate = "";
    wantedDate = "at ${DateFormat('hh:mm a').format(lastSeenDate)}";
    if (lastSeenDate.day == now.day) {
    } else if (lastSeenDate.day == now.subtract(Duration(days: 1)).day) {
      wantedDate = "yesterday $wantedDate";
    } else {
      wantedDate = "at ${DateFormat('hh:mm a dd-MM-yy').format(lastSeenDate)}";
    }
    _getLastSeenFor(userId).value = "last seen $wantedDate";
  }

  RxString _getLastSeenFor(int userId) {
    return lastSeen.putIfAbsent(userId, () => RxString("last seen recently"));
  }

  RxString getLastMessageTimeFor(int conversationId) {
    return lastMessageTime.putIfAbsent(conversationId, () => RxString(""));
  }

  RxString getLastMessageFor(int conversationId) {
    return lastMessageFor.putIfAbsent(conversationId, () => RxString("null"));
  }
}
