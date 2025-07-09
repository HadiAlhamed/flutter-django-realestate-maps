// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate/models/message.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/textstyles/text_colors.dart';

class ChatBubble extends StatelessWidget {
  // final Message message; // Your message model
  final Message message;
  final double screenWidth;
  const ChatBubble({
    super.key,
    required this.message,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    bool isMe = message.senderId == Api.box.read('currentUserId');
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? primaryColor
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.blueGrey
                  : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              (message.content == null || !isRTL(message.content!))
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
          children: [
            Text("${message.fileUrl != null ? "photo" : message.content}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  DateFormat("hh:mm a").format(message.createdAt),
                  textAlign: TextAlign.right,
                ),
                if (isMe)
                  const SizedBox(
                    width: 2,
                  ),
                if (isMe && message.isRead)
                  Icon(Icons.done_all, color: Colors.green),
                if (isMe && !message.isRead) Icon(Icons.check),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool isRTL(String text) {
    final rtlRegex = RegExp(r'^[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return rtlRegex.hasMatch(text.trim());
  }
}
