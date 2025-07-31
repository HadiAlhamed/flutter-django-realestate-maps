import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/notifications_controllers/notifications_controller.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/widgets/notifications_widgets/notification_tile.dart';

class NotificationsListPage extends StatefulWidget {
  const NotificationsListPage({super.key});

  @override
  State<NotificationsListPage> createState() => _NotificationsListPageState();
}

class _NotificationsListPageState extends State<NotificationsListPage> {
  final ScrollController _scrollController = ScrollController();
  final NotificationsController notificationsController =
      Get.find<NotificationsController>();

  // Key used to manipulate AnimatedList programmatically (insert/delete)
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    notificationsController.setInsertCallback((notif) {
      _listKey.currentState
          ?.insertItem(0, duration: const Duration(milliseconds: 300));
    });
    // Fetch the first page of notifications after the frame is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialNotifications();
    });

    // Scroll listener to trigger pagination (load more when nearing bottom)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !notificationsController.isLoading.value &&
          notificationsController.hasMoreData()) {
        _fetchMoreNotifications();
      }
    });
  }

  Future<void> _fetchInitialNotifications() async {
    final newItems = await notificationsController
        .getNotifications(); // Returns List<Notification>
    for (int i = 0; i < newItems.length; i++) {
      _listKey.currentState?.insertItem(i);
    }
  }

  Future<void> _fetchMoreNotifications() async {
    final startIndex = notificationsController.notifications.length;
    final newItems = await notificationsController.getNotifications();
    for (int i = 0; i < newItems.length; i++) {
      _listKey.currentState?.insertItem(startIndex + i);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Main UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.black45
                      : const Color.fromARGB(133, 205, 175, 192),
                  primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Reactive UI for notification list
          Obx(() {
            final notifs = notificationsController.notifications;
            if (notificationsController.notifications.isEmpty) {
              return Center(child: const Text("You have no notifications yet"));
            }
            return AnimatedList(
              key: _listKey,
              controller: _scrollController,
              initialItemCount: notificationsController.notifications.length +
                  (notificationsController.isLoading.value
                      ? 1
                      : 0), //if loading add a space for the loading indicator
              itemBuilder: (context, index, animation) {
                // Show loading indicator at bottom
                if (index == notifs.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notif = notifs[index];

                return SizeTransition(
                  sizeFactor: animation,
                  child: NotificationTile(
                    key: ValueKey(
                        notif.id), // Ensures Flutter reuses widget properly
                    notification: notif,
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
