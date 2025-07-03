import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/bottom_navigation_bar_controller.dart';
import 'package:real_estate/widgets/chat_tile.dart';
import 'package:real_estate/widgets/my_bottom_navigation_bar.dart';
import 'package:real_estate/widgets/my_floating_action_button.dart';

class ChatsPage extends StatelessWidget {
  ChatsPage({super.key});
  final BottomNavigationBarController bottomController =
      Get.find<BottomNavigationBarController>();
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final double screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: AnimationLimiter(
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                verticalOffset: 50.0,
                child: ScaleAnimation(
                  scale: 0.8,
                  child: FadeInAnimation(
                    curve: Easing.legacyAccelerate,
                    child: ChatTile(
                      name: 'Joe Biden',
                      lastMessage: 'please call me as fast as possible',
                      lastMessageTime: "12:25 AM",
                      newMessages: 4,
                      screenWidth: screenWidth,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: const MyFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar:
          MyBottomNavigationBar(bottomController: bottomController),
    );
  }
}
