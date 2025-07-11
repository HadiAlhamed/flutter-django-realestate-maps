import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/chat_controller.dart';
import 'package:real_estate/models/message.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/chat_apis/chat_apis.dart';
import 'package:real_estate/widgets/chat_bubble.dart';
import 'package:real_estate/widgets/message_input_bar.dart';

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
    index = args['index'];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchMessages(); // fetch messages after UI is ready
      _scrollToBottom(); // scroll to bottom after fetching
    });
    ever(chatController.getMessagesFor(chatController.currentConvId), (_) {
      print("Messages updated, scrolling down...");
      _scrollToBottom();
    });
  }

  Future<void> _fetchMessages() async {
    print("currentUserId from chatPage : ${Api.box.read('currentUserId')}");
    chatController.connectToChat(
      conversationId: chatController.currentConvId,
      currentUserId: Api.box.read('currentUserId'),
    );
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
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/person.jpg'),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "${chatController.chats[index].otherUserFirstName} ${chatController.chats[index].otherUserLastName}"),
                Obx(() {
                  bool isOtherTyping = chatController
                      .isTyping[chatController.currentConvId]!.value;

                  bool onlineStatus = chatController
                      .isOtherUserOnline[chatController.currentConvId]!.value;
                  return Text(
                    isOtherTyping
                        ? "typing ..."
                        : onlineStatus
                            ? "Online"
                            : chatController
                                .lastSeen[chatController.currentConvId]!.value,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: isOtherTyping ? Colors.green : Colors.grey,
                        ),
                  );
                }),
              ],
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
