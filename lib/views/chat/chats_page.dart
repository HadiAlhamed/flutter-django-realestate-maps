import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_estate/controllers/bottom_navigation_bar_controller.dart';
import 'package:real_estate/controllers/chat_controller.dart';
import 'package:real_estate/models/conversations/conversation.dart';
import 'package:real_estate/models/conversations/paginated_conversation.dart';
import 'package:real_estate/services/chat_apis/chat_apis.dart';
import 'package:real_estate/widgets/chat_tile.dart';
import 'package:real_estate/widgets/my_bottom_navigation_bar.dart';
import 'package:real_estate/widgets/my_floating_action_button.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final BottomNavigationBarController bottomController =
      Get.find<BottomNavigationBarController>();

  final ChatController chatController = Get.find<ChatController>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchConversations();
    });
  }

  Future<void> _fetchConversations() async {
    if (chatController.fetchedAll) return;
    chatController.changeLoadingChats(true);
    chatController.chats.clear();
    //make use of the pagination concept , current implementation is wrong
    PaginatedConversation pConversation = await ChatApis.getConversations();
    do {
      for (Conversation conversation in pConversation.conversations) {
        chatController.add(conversation);
      }
    } while (pConversation.nextUrl != null);
    chatController.fetchedAll = true;
    await Future.delayed(const Duration(milliseconds: 500));
    chatController.changeLoadingChats(false);
  }

  @override
  dispose() {
    chatController.disconnect(exceptId: chatController.anyConvId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final double screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: AnimationLimiter(
        child: Obx(() {
          if (chatController.loadingChats.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (chatController.chats.isEmpty) {
            return const Center(
              child: Text("You have no chats yet."),
            );
          }

          return ListView.builder(
            itemCount: chatController.chats.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  verticalOffset: 50.0,
                  child: ScaleAnimation(
                    scale: 0.8,
                    child: FadeInAnimation(
                      curve: Easing.legacyAccelerate,
                      child: Obx(
                        () {
                          return ChatTile(
                            key: ValueKey(chatController.chats[index].id),
                            isOnline: chatController
                                .getIsOtherUserOnlineFor(
                                    chatController.chats[index].otherUserId)
                                .value,
                            conversationId: chatController.chats[index].id,
                            index: index,
                            name:
                                "${chatController.chats[index].otherUserFirstName} ${chatController.chats[index].otherUserLastName}",
                            lastMessage: chatController
                                    .getIsTypingFor(
                                        chatController.chats[index].otherUserId)
                                    .value
                                ? "typing ..."
                                : chatController
                                    .lastMessageFor[
                                        chatController.chats[index].id]
                                    ?.value,
                            lastMessageTime: chatController.lastMessageTime[
                                        chatController.chats[index].id] ==
                                    null
                                ? ""
                                : chatController
                                    .lastMessageTime[
                                        chatController.chats[index].id]!
                                    .value,
                            newMessages: chatController
                                .unreadCount[chatController.chats[index].id]!
                                .value,
                            screenWidth: screenWidth,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: const MyFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar:
          MyBottomNavigationBar(bottomController: bottomController),
    );
  }

  String handleLastMessageTime(DateTime lastMessageTime) {
    DateTime now = DateTime.now();
    String wantedDate = "";
    wantedDate = "at ${DateFormat('hh:mm a').format(lastMessageTime)}";
    if (lastMessageTime.day == now.day) {
    } else if (lastMessageTime.day == now.subtract(Duration(days: 1)).day) {
      wantedDate = "yesterday $wantedDate";
    } else {
      wantedDate = DateFormat('dd/MM/yy').format(lastMessageTime);
    }
    return wantedDate;
  }
}
