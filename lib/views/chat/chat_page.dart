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
    // TODO: implement initState
    super.initState();
    if (chatController.currentConvId != chatController.anyConvId) {
      chatController.connectToChat(
          conversationId: chatController.currentConvId,
          currentUserId: Api.box.read('currentUserId'));
    }

    index = args['index'];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchMessages(); // fetch messages after UI is ready
      _scrollToBottom(); // scroll to bottom after fetching
    });
    ever(chatController.getMessagesFor(chatController.currentConvId), (_) {
      print("Messages updated, scrolling down...");
      _scrollToBottom();
    });
    //clear messageHistory for this person for the chat
    //remove notification for this chat if exists
    chatController.clearMessageHistoryFor(chatController.currentConvId);
  }

  Future<void> _fetchMessages() async {
    print("currentUserId from chatPage : ${Api.box.read('currentUserId')}");

    chatController.getMessagesFor(chatController.currentConvId).clear();
    chatController.getMessagesFor(chatController.currentConvId).value =
        await ChatApis.getMessagesFor(chatController.currentConvId);
    //send a realtime markas read for other
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
  }

  @override
  dispose() {
    chatController.sendTypingStatus(false, chatController.currentConvId);
    chatController.disconnect(onlyThis: chatController.currentConvId);
    chatController.currentConvId = -1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("chatPage :: build :: currentIndex : $index");
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final double screenHeight = MediaQuery.sizeOf(context).height;
    // Scroll to bottom

    return Scaffold(
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
              backgroundImage: chatController.chats[index].otherUserPhotoUrl !=
                      null
                  ? NetworkImage(chatController.chats[index].otherUserPhotoUrl!)
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
                                  color:
                                      onlineStatus ? primaryColor : Colors.grey,
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
      body: Column(
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
                                message: chatController.messages[
                                    chatController.currentConvId]![index]),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          Obx(() {
            print("Obx :: index : $index");
            if (chatController
                .getIsTypingFor(chatController.chats[index].otherUserId)
                .value) {
              return TypingIndicatorMessage();
            }
            return const SizedBox.shrink();
          }),
          MessageInputBar(
            screenHeight: screenHeight,
          ),
        ],
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
