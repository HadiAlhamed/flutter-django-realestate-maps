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

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();

    // Setup insert animation callback
    notificationsController.setInsertCallback((notif) {
      _listKey.currentState
          ?.insertItem(0, duration: const Duration(milliseconds: 300));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialNotifications();
    });

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !notificationsController.isLoading.value &&
        notificationsController.hasMoreData()) {
      _fetchMoreNotifications();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialNotifications() async {
    final newItems = await notificationsController.getNotifications();
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
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) return; // Only run if the pop actually happens
        await notificationsController.markAllRead(); // Safe async operation
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Notifications"),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black45
              : const Color.fromARGB(133, 205, 175, 192),
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

            Obx(() {
              final notifs = notificationsController.notifications;
              final isLoading = notificationsController.isLoading.value;

              if (isLoading && notifs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (notifs.isEmpty) {
                return const Center(
                    child: Text("You have no notifications yet"));
              }

              return AnimatedList(
                key: _listKey,
                controller: _scrollController,
                initialItemCount: notifs.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index, animation) {
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
                      key: ValueKey(notif.id),
                      notification: notif,
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
