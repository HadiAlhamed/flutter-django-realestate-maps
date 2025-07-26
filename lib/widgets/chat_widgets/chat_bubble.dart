// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate/models/conversations/message.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/chat_apis/chat_apis.dart';
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
        padding: message.messageType == 'image'
            ? const EdgeInsets.all(4)
            : const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? primaryColor
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.blueGrey
                  : Colors.blueGrey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: message.content == null
              ? CrossAxisAlignment.center
              : (!isRTL(message.content!))
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
          children: [
            if (message.messageType == 'text') ...[
              Text("${message.content}")
            ] else if (message.messageType == 'image' &&
                message.fileUrl != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(16), // adjust radius as needed
                    child: GestureDetector(
                      onTap: () async {
                        await ChatApis.openRemoteFile(message.fileUrl!);
                      },
                      child: Image.network(
                        message.fileUrl!,
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            child: const Center(
                                child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 6,
                    child: messageTimeAndSeenWidget(isMe),
                  )
                ],
              )
            ] else if (message.messageType == 'pdf') ...[
              GestureDetector(
                onTap: () async {
                  await ChatApis.openRemoteFile(message.fileUrl!);
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _extractFileName(message.fileUrl!),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
            if (message.messageType != 'image') messageTimeAndSeenWidget(isMe),
          ],
        ),
      ),
    );
  }

  Row messageTimeAndSeenWidget(bool isMe) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        //edit here
        Text(
          DateFormat("hh:mm a").format(message.createdAt.toLocal()),
          textAlign: TextAlign.right,
          style: TextStyle(color: Colors.white),
        ),
        if (isMe)
          const SizedBox(
            width: 2,
          ),
        if (isMe && message.isRead) Icon(Icons.done_all, color: Colors.white),
        if (isMe && !message.isRead) Icon(Icons.check),
      ],
    );
  }

  String _extractFileName(String url) {
    return url.split('/').last;
  }

  bool isRTL(String text) {
    final rtlRegex = RegExp(r'^[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return rtlRegex.hasMatch(text.trim());
  }
}
