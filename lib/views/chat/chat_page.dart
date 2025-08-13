import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/chat_controllers/chat_controller.dart';
import 'package:real_estate/models/conversations/message.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/chat_services/chat_apis.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/widgets/chat_widgets/chat_bubble.dart';
import 'package:real_estate/widgets/chat_widgets/message_input_bar.dart';
import 'package:real_estate/widgets/chat_widgets/typing_indicator.dart';
import 'package:real_estate/widgets/chat_widgets/typing_indicator_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController chatController = Get.find<ChatController>();
  final ScrollController _scrollController = ScrollController();

  final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;

  late int index;

  @override
  void initState() {
    super.initState();
    debugPrint("initState :: chatPage :: running");
    debugPrint(
        "initState :: chatPage :: anyConvId :: ${chatController.anyConvId}");

    try {
      debugPrint(
          "chatController.currentConvId = ${chatController.currentConvId}");

      if (args['conversationId'] != null) {
        chatController.currentConvId = args['conversationId'];
      }
      if (args['index'] == null) {
        index = chatController.chats.indexWhere((chat) {
          return chat.id == chatController.currentConvId;
        });
      } else {
        index = args['index'];
      }
    } catch (e, s) {
      debugPrint("initState error: $e\n$s");
    }
    debugPrint(
        "chatController.currentConvId = ${chatController.currentConvId}");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        debugPrint(
            "are messages empty ? ${chatController.getMessagesFor(chatController.currentConvId).isEmpty}");

        if (chatController.getNeedFirstFetch(chatController.currentConvId)) {
          await _fetchMessages();
          chatController.needFirstFetch[chatController.currentConvId] = false;
        }

        if (chatController.currentConvId != chatController.anyConvId) {
          await chatController.connectToChat(
            conversationId: chatController.currentConvId,
            currentUserId: Api.box.read('currentUserId'),
          );
        }
        //markAsRead for each time we open the chatPage will be handled by an api
        //that returns messageIds of unReadMessages
        //update it later when api ready
        List<Message> list =
            chatController.getMessagesFor(chatController.currentConvId);
        List<String> messageIds = [];
        for (int i = list.length - 1; i >= 0 && messageIds.length < 15; i--) {
          if (list[i].senderId != Api.box.read("currentUserId")) {
            messageIds.add(list[i].id.toString());
          }
        }
        print("init chat page!!!!!!!!!!!");
        print(messageIds);
        if (messageIds.isNotEmpty) {
          chatController.markAsRead(messageIds, chatController.currentConvId);
        }
        _scrollToBottom();
      } catch (e, s) {
        print("post frame error: $e\n$s");
      }
    });

    ever(chatController.getMessagesFor(chatController.currentConvId), (_) {
      print("Messages updated, scrolling down...");
      _scrollToBottom();
    });

    chatController.clearMessageHistoryFor(chatController.currentConvId);
  }

  Future<void> _fetchMessages() async {
    print("currentUserId from chatPage : ${Api.box.read('currentUserId')}");

    chatController.getMessagesFor(chatController.currentConvId).clear();
    chatController.getMessagesFor(chatController.currentConvId).value =
        await ChatApis.getMessagesFor(chatController.currentConvId);
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("chatPage :: build :: currentIndex : $index");
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final double screenHeight = MediaQuery.sizeOf(context).height;
    // Scroll to bottom

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        chatController.sendTypingStatus(false, chatController.currentConvId);
        chatController.disconnect(onlyThis: chatController.currentConvId);
        chatController.currentConvId = -1; //might cause problems , check it
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.06,
                backgroundImage:
                    chatController.chats[index].otherUserPhotoUrl != null
                        ? NetworkImage(
                            chatController.chats[index].otherUserPhotoUrl!)
                        : const AssetImage('assets/images/person.jpg'),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${chatController.chats[index].otherUserFirstName} ${chatController.chats[index].otherUserLastName}",
                      overflow: TextOverflow.ellipsis,
                    ),
                    Obx(() {
                      bool isOtherTyping = chatController
                          .isTyping[chatController.chats[index].otherUserId]!
                          .value;

                      bool onlineStatus = chatController
                          .isOtherUserOnline[
                              chatController.chats[index].otherUserId]!
                          .value;
                      return isOtherTyping
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "typing",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: primaryColor,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(width: 4),
                                TypingIndicator(dotColor: primaryColor),
                              ],
                            )
                          : Text(
                              onlineStatus
                                  ? "Online"
                                  : chatController
                                      .lastSeen[chatController
                                          .chats[index].otherUserId]!
                                      .value,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: onlineStatus
                                        ? primaryColor
                                        : Colors.grey,
                                  ),
                            );
                    }),
                  ],
                ),
              )
              // other widgets if needed
            ],
          ),
        ),
        body: Stack(
          children: [
            // Background logo (centered, semi-transparent)
            // Background logo (centered, semi-transparent)
            Positioned.fill(
              child: Stack(
                children: [
                  Center(
                    child: Opacity(
                      opacity: 0.25, // softer logo
                      child: Image.asset(
                        'assets/images/Aqari_logo_primary_towers.png',
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Gentle gradient overlay to soften the backdrop
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(
                              (255 * 0.05).round()), // subtle top fade
                          Colors.black.withAlpha(
                              (0.1 * 255).round()), // more fade near input area
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chat content
            Column(
              children: [
                Expanded(
                  child: AnimationLimiter(
                    child: Obx(() {
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: chatController
                            .getMessagesFor(chatController.currentConvId)
                            .length,
                        itemBuilder: (context, index) {
                          Message message = Message(
                            id: 123,
                            senderId: 5,
                            senderFirstName: "asdf",
                            senderLastName: "asd",
                            messageType: "text",
                            createdAt: DateTime.now(),
                            isRead: true,
                          );
                          try {
                            message = chatController
                                .messages[chatController.currentConvId]![index];
                          } catch (e) {
                            debugPrint("chatPage :: MessageError :: $e");
                          }

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: ScaleAnimation(
                                scale: 0.9,
                                child: FadeInAnimation(
                                  child: ChatBubble(
                                    screenWidth: screenWidth,
                                    message: message,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),

                // Typing indicator
                Obx(() {
                  if (chatController
                      .getIsTypingFor(chatController.chats[index].otherUserId)
                      .value) {
                    return TypingIndicatorMessage();
                  }
                  return const SizedBox.shrink();
                }),

                // Input bar
                MessageInputBar(screenHeight: screenHeight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("ScrollController has clients? ${_scrollController.hasClients}");
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        print("Scrolling to maxScrollExtent: $maxScroll");
        _scrollController.animateTo(
          maxScroll,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        print("No clients attached to scrollController");
      }
    });
  }
}
