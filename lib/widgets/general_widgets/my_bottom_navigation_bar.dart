import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/main_controllers/bottom_navigation_bar_controller.dart';
import 'package:real_estate/controllers/chat_controllers/chat_controller.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final BottomNavigationBarController bottomController;
  final ChatController chatController = Get.find<ChatController>();
  MyBottomNavigationBar({
    super.key,
    required this.bottomController,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGapEnd = bottomController.selectedIndex != 2;

    return GetBuilder<BottomNavigationBarController>(
      init: bottomController,
      builder: (controller) => AnimatedBottomNavigationBar.builder(
        itemCount: 5,
        tabBuilder: (index, isActive) {
          final color = isActive ? primaryColor : greyText;
          final isChatIcon = index == 1;
          if (!isChatIcon) {
            return IconTheme(
              data: IconThemeData(
                color: color,
                size: 28,
              ),
              child: Icon(_iconDataFor(index)),
            );
          }
          return Obx(() {
            final unreadCount = chatController.totalUnreadCount.value;
            return SizedBox(
              width: 40, // match the icon size + room for badge
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: IconTheme(
                      data: IconThemeData(
                        color: color,
                        size: 28,
                      ),
                      child: Icon(_iconDataFor(index)),
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: bottomController.selectedIndex == 2 ? 18 : 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Center(
                          child: Text(
                            '${unreadCount > 99 ? '99+' : unreadCount}',
                            style: TextStyle(
                              color: Colors.grey[300]!,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          });
        },
        activeIndex: controller.selectedIndex,
        gapLocation: isGapEnd ? GapLocation.end : GapLocation.none,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        leftCornerRadius: 24,
        rightCornerRadius: 0,
        onTap: (index) => handleBottomNavigation(index),
      ),
    );
  }

  IconData _iconDataFor(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.message_outlined;
      case 2:
        return Icons.share_location_sharp;
      case 3:
        return Icons.favorite;
      case 4:
      default:
        return Icons.person;
    }
  }

  void handleBottomNavigation(int index) {
    debugPrint("bottom navigation bar index : $index");
    bottomController.changeSelectedIndex(index: index);
    if (index == 0) {
      Get.offNamed('/home');
    } else if (index == 1) {
      Get.offNamed("/chatsPage");
    } else if (index == 2) {
      Get.offNamed('/openStreetMap', arguments: {
        'isNewProperty': false,
      });
    } else if (index == 3) {
      Get.offNamed('/favoritesPage');
    } else if (index == 4) {
      Get.offNamed('/accountPage');
    }
  }
}
