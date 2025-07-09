import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/chat_controller.dart';
import 'package:real_estate/textstyles/text_colors.dart';

class ChatTile extends StatelessWidget {
  final int conversationId;
  final String name;
  final String lastMessage;
  final String lastMessageTime;
  final int newMessages;
  final double screenWidth;
  final ChatController chatController = Get.find<ChatController>();
  final int index;
  ChatTile({
    super.key,
    required this.conversationId,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.newMessages,
    required this.screenWidth,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: () {
          chatController.currentConvId = conversationId;
          Get.toNamed(
            '/chatPage',
            arguments: {
              'index': index,
            },
          );
        },
        title: Text(name),
        subtitle: Text(lastMessage),
        leading: CircleAvatar(
          radius: screenWidth * 0.07,
          backgroundImage: const AssetImage('assets/images/person.jpg'),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(lastMessageTime),
            if (newMessages > 0)
              CircleAvatar(
                radius: screenWidth * 0.03,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? primaryColor
                    : primaryColorInactive,
                child: Text(newMessages.toString()),
              ),
          ],
        ),
      ),
    );
  }
}
