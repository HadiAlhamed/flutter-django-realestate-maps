import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/chat_controller.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/widgets/typing_indicator.dart';

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
            : Text(
                lastMessage,
                overflow: TextOverflow.ellipsis, // Shows ... at the end
                maxLines: 2, // Ensures text stays in a single lines
              ),
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
