import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:real_estate/widgets/chat_bubble.dart';
import 'package:real_estate/widgets/message_input_bar.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key});
  final List<String> messages = [
    "hi",
    "hi hello how are youhi hello how are youhi hello how are youhi hello how are you",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi hello how are you",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi hello how are you",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi hello how are you",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi hello how are you",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi hello how are you",
    "hi",
    "hi",
    "hi",
    "hi",
    "hi",
  ];
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final double screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/person.jpg'),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Joe Biden"),
                Text(
                  "last seen recently",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.grey,
                      ),
                )
              ],
            )
            // other widgets if needed
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: ScaleAnimation(
                        scale: 0.9,
                        child: FadeInAnimation(
                          
                          child: ChatBubble(
                              screenWidth: screenWidth,
                              isMe: index % 2 == 0,
                              message: messages[index]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          MessageInputBar(
            screenHeight: screenHeight,
            onSend: (String value) {}),
        ],
      ),
    );
  }
}
