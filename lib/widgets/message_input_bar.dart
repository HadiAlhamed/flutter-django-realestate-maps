import 'package:flutter/material.dart';
import 'package:real_estate/textstyles/text_colors.dart';

class MessageInputBar extends StatefulWidget {
  final Function(String) onSend;
  final double screenHeight;
  const MessageInputBar({super.key, required this.onSend, required this.screenHeight});

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _controller = TextEditingController();

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
            icon: const Icon(Icons.send , color : primaryColorInactive),
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                widget.onSend(_controller.text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
