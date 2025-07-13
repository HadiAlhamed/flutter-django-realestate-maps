import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/chat_controller.dart';
import 'package:real_estate/textstyles/text_colors.dart';

class MessageInputBar extends StatefulWidget {
  final double screenHeight;

  const MessageInputBar({super.key, required this.screenHeight});

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _controller = TextEditingController();
  final ChatController chatController = Get.find<ChatController>();
  bool isTyping = false;
  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end, // Aligns send button to bottom

        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: widget.screenHeight * 0.22,
              ),
              child: TextField(
                onChanged: (value) {
                  if (value.trim().isNotEmpty) {
                    if (!isTyping) {
                      isTyping = true;
                      chatController.sendTypingStatus(
                          isTyping, chatController.currentConvId);
                    }
                  } else {
                    if (isTyping) {
                      isTyping = false;
                      chatController.sendTypingStatus(
                          isTyping, chatController.currentConvId);
                    }
                  }
                },
                maxLines: null,
                controller: _controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintText: "Type a message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: primaryColorInactive),
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                chatController.sendTextMessage(
                  _controller.text.trim(),
                  chatController.currentConvId,
                );
                isTyping = false;
                chatController.sendTypingStatus(
                    isTyping, chatController.currentConvId);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  bool isRTL(String text) {
    final rtlRegex = RegExp(r'^[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return rtlRegex.hasMatch(text.trim());
  }
}
