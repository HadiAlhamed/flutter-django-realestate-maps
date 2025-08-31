import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/chat_controllers/chat_controller.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/widgets/chat_widgets/typing_indicator.dart';

class ChatTile extends StatelessWidget {
  final int conversationId;
  final String name;
  final String? lastMessage;
  final String lastMessageTime;
  final int newMessages;
  final double screenWidth;
  final ChatController chatController = Get.find<ChatController>();
  final int index;
  final bool isOnline;

  ChatTile({
    super.key,
    required this.conversationId,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.newMessages,
    required this.screenWidth,
    required this.index,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    print("lastMessage : $lastMessage");
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: () async {
          chatController.currentConvId = conversationId;

          await Get.toNamed(
            '/chatPage',
            arguments: {
              'index': index,
            },
          );
        },
        title: Text(name),
        subtitle: lastMessage == 'typing ...'
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "typing",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: primaryColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(width: 4),
                  TypingIndicator(dotColor: primaryColor),
                ],
              )
            : lastMessage == null || lastMessage == "null"
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: const Icon(
                      Icons.file_copy,
                    ),
                  )
                : Text(
                    lastMessage!,
                    overflow: TextOverflow.ellipsis, // Shows ... at the end
                    maxLines: 2, // Ensures text stays in a single lines
                  ),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: screenWidth * 0.07,
              backgroundImage: chatController.chats[index].otherUserPhotoUrl !=
                      null
                  ? NetworkImage(chatController.chats[index].otherUserPhotoUrl!)
                  : const AssetImage('assets/images/person.jpg'),
            ),
            if (isOnline)
              Positioned(
                bottom: 0,
                right: 1,
                child: CircleAvatar(
                  backgroundColor: primaryColor,
                  radius: screenWidth * 0.07 * 0.22,
                ),
              ),
          ],
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
