import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/chat_controllers/chat_controller.dart';
import 'package:real_estate/models/conversations/conversation.dart';
import 'package:real_estate/models/conversations/paginated_conversation.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/chat_apis/chat_apis.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  final ChatController chatController = Get.find<ChatController>();
  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("App in Foreground");
        // Reconnect sockets or resume tasks
        _handleResumed();
        break;
      case AppLifecycleState.paused:
        print("App in Background");
        // Pause operations or release resources
        // _handlePaused();
        break;
      case AppLifecycleState.detached:
        print("App Terminated or detached");
        _handleDetached();
        // Clean up or save data
        break;
      case AppLifecycleState.inactive:
        print("App is inactive");
        break;
      case AppLifecycleState.hidden:
        print("App is hidden ??");
        break;
      // TODO: Handle this case.
    }
  }

  Future<void> _handleResumed() async {
    if (Get.currentRoute == '/chatsPage' || Get.currentRoute == '/chatPage') {
      await _fetchConversations();
    }

    if (chatController.currentConvId != -1) {
      chatController.connectToChat(
        conversationId: chatController.anyConvId,
        currentUserId: Api.box.read("currentUserId"),
      );
    }
  }

  void _handlePaused() {
    chatController.disconnect();
    chatController.clear(leaveConvIds: true);
  }

  void _handleDetached() {
    chatController.clear();
  }

  Future<void> _fetchConversations() async {
    if (chatController.fetchedAll) return;
    // chatController.chats.clear();
    //make use of the pagination concept , current implementation is wrong
    PaginatedConversation pConversation = await ChatApis.getConversations();
    do {
      for (Conversation conversation in pConversation.conversations) {
        chatController.add(conversation);
      }
    } while (pConversation.nextUrl != null);
    chatController.fetchedAll = true;
  }
}
