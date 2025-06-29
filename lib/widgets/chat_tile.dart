import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/textstyles/text_colors.dart';

class ChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String lastMessageTime;
  final int newMessages;
  final double screenWidth;
  const ChatTile(
      {super.key,
      required this.name,
      required this.lastMessage,
      required this.lastMessageTime,
      required this.newMessages, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: () {
          Get.toNamed('/chatPage');
        },
        title: Text(name),
        subtitle: Text(lastMessage),
        leading: CircleAvatar(
          radius: screenWidth * 0.07,
          backgroundImage: const AssetImage('assets/images/person.jpg'),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(lastMessageTime),
            CircleAvatar(
              radius: screenWidth * 0.03,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? primaryColor
                  : primaryColorInactive,
              child:  Text(newMessages.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
