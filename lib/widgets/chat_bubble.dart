// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:real_estate/textstyles/text_colors.dart';

class ChatBubble extends StatelessWidget {
  // final Message message; // Your message model
  final bool isMe;
  final String message;
  final double screenWidth;
  const ChatBubble({
    super.key,
    required this.isMe,
    required this.message,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Text(message),
      ),
    );
  }
}
