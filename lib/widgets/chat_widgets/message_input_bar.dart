import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:real_estate/controllers/chat_controllers/chat_controller.dart';
import 'package:real_estate/controllers/chat_controllers/message_input_controller.dart';
import 'package:real_estate/controllers/main_controllers/my_points_controller.dart';
import 'package:real_estate/controllers/main_controllers/profile_controller.dart';
import 'package:real_estate/models/conversations/chat_status_check.dart';
import 'package:real_estate/services/chat_services/chat_apis.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/conversations/activate_chat_model.dart';

class MessageInputBar extends StatefulWidget {
  final double screenHeight;
  final int index;
  const MessageInputBar({
    super.key,
    required this.screenHeight,
    required this.index,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _controller = TextEditingController();
  final ChatController chatController = Get.find<ChatController>();
  final MessageInputController messageController =
      Get.find<MessageInputController>();
  final MyPointsController myPointsController = Get.find<MyPointsController>();
  final ProfileController profileController = Get.find<ProfileController>();

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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: widget.screenHeight * 0.22,
        ),
        child: TextField(
          onChanged: (value) {
            DateTime? expiresAt = chatController.chats[widget.index].expiresAt;
            if (expiresAt != null && expiresAt.compareTo(DateTime.now()) <= 0) {
              return;
            }
            if (value.trim().isNotEmpty) {
              if (!messageController.isTyping) {
                messageController.changeIsTyping(true);
                chatController.sendTypingStatus(
                    messageController.isTyping, chatController.currentConvId);
              }
            } else {
              if (messageController.isTyping) {
                messageController.changeIsTyping(false);
                chatController.sendTypingStatus(
                    messageController.isTyping, chatController.currentConvId);
              }
            }
          },
          maxLines: null,
          controller: _controller,
          decoration: InputDecoration(
            filled: true,
            suffixIcon: Container(
              constraints:
                  const BoxConstraints(maxWidth: 96), // Controls icon row width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GetBuilder<MessageInputController>(
                    init: messageController,
                    id: "isTyping",
                    builder: (controller) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: messageController.isTyping
                          ? const SizedBox.shrink()
                          : IconButton(
                              key: const ValueKey("attach"),
                              icon: const Icon(Icons.attach_file),
                              onPressed: _showAttachmentOptions,
                              iconSize: 25,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                    ),
                  ),
                  GetBuilder<MessageInputController>(
                    init: messageController,
                    id: "isTyping",
                    builder: (controller) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                      child: IconButton(
                        key: ValueKey(controller
                            .isTyping), // Needed for switch to trigger

                        icon: Icon(
                          Icons.send,
                          color: messageController.isTyping
                              ? primaryColor
                              : primaryColorInactive,
                        ),
                        onPressed: () {
                          DateTime? expiresAt =
                              chatController.chats[widget.index].expiresAt;
                          DateTime? activatedAt =
                              chatController.chats[widget.index].activatedAt;
                          if (expiresAt != null &&
                              expiresAt.compareTo(DateTime.now()) <= 0) {
                            _controller.clear();
                            //use Get.dialog instead of snackbar
                            //so that the user is given the choice to reactivate this chat
                            _handleActivateReactivate(
                              activatedAt: activatedAt!,
                              expiresAt: expiresAt,
                            );

                            return;
                          }
                          if (_controller.text.trim().isNotEmpty) {
                            messageController.changeIsTyping(false);
                            chatController.sendTypingStatus(
                                messageController.isTyping,
                                chatController.currentConvId);
                            chatController.sendMessage(
                              conversationId: chatController.currentConvId,
                              content: _controller.text.trim(),
                            );
                            _controller.clear();
                          }
                        },
                        iconSize: 25,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            hintText: "Type a message...",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    DateTime? expiresAt = chatController.chats[widget.index].expiresAt;
    DateTime? activatedAt = chatController.chats[widget.index].activatedAt;
    if (expiresAt != null && expiresAt.compareTo(DateTime.now()) <= 0) {
      _controller.clear();
      //use Get.dialog instead of snackbar
      //so that the user is given the choice to reactivate this chat
      _handleActivateReactivate(
        activatedAt: activatedAt!,
        expiresAt: expiresAt,
      );

      return;
    }
    Get.bottomSheet(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                await handleAddingChatImage(false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                await handleAddingChatImage(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              onTap: handleAddingChatPdf,
            ),
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void handleAddingChatPdf() async {
    // Handle PDF selection
    FilePickerResult? pdfFile = await FilePicker.platform.pickFiles(
      allowedExtensions: ['pdf'],
      type: FileType.custom,
    );
    if (pdfFile != null && pdfFile.files.isNotEmpty) {
      String? filePath = pdfFile.files.single.path;
      if (filePath != null) {
        File file = File(filePath);
        final String? uploadedFileUrl = await ChatApis.uploadFile(
          file: file,
        );
        if (uploadedFileUrl != null) {
          chatController.sendMessage(
            conversationId: chatController.currentConvId,
            fileUrl: uploadedFileUrl,
          );
        }
      }
    }
    Get.back();
  }

  Future<void> handleAddingOneImage(String imagePath) async {
    final File originalFile = File(imagePath);

    if (!originalFile.existsSync()) {
      print("❌ Image file does not exist at: $imagePath");
      return;
    }
    XFile? compressedFile = await ChatApis.compressImage(originalFile);
    if (compressedFile == null) {
      print("❌ Image compression failed");
      return;
    }

    print("✅ Compressed image size: ${await compressedFile.length()} bytes");

    final uploadedFileUrl =
        await ChatApis.uploadFile(file: File(compressedFile.path));
    if (uploadedFileUrl != null) {
      chatController.sendMessage(
        conversationId: chatController.currentConvId,
        fileUrl: uploadedFileUrl,
      );
    }
  }

  Future<void> handleAddingChatImage(bool fromGallery) async {
    // Handle gallery pick

    if (fromGallery) {
      List<XFile?> images = await messageController.imagepicker.pickMultiImage(
        limit: 10,
      );
      if (images.isNotEmpty) {
        for (XFile? image in images) {
          if (image != null) {
            await handleAddingOneImage(image.path);
          }
        }
      }
    } else {
      XFile? image = await messageController.imagepicker.pickImage(
        source: ImageSource.camera,
      );
      await Future.delayed(const Duration(milliseconds: 100));
      if (image != null) {
        await handleAddingOneImage(image.path);
      }
    }
    Get.back();
  }

  bool isRTL(String text) {
    final rtlRegex = RegExp(r'^[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return rtlRegex.hasMatch(text.trim());
  }

  Future<dynamic> _handleActivateReactivate({
    required DateTime expiresAt,
    required DateTime activatedAt,
  }) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Get.dialog(
      barrierDismissible: true,
      Center(
        // Center the dialog manually
        child: Material(
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: 0.5 * screenHeight,
              maxWidth: 0.9 * screenWidth,
            ),
            padding: const EdgeInsets.all(18),
            color: Colors.white,
            // alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "You have activated this booking chat in ",
                        ),
                        TextSpan(
                          text: DateFormat().format(activatedAt),
                          style: TextStyle(
                            color: primaryColor, // Highlighted color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: ", ends at ",
                        ),
                        TextSpan(
                          text: DateFormat().format(expiresAt),
                          style: TextStyle(
                            color: primaryColor, // Highlighted color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ", you can reactivate it for ",
                        ),
                        TextSpan(
                          text: "50.00 Aqari Points",
                          style: TextStyle(
                            color: primaryColor, // Highlighted color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge, // Default style
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        child: Text(
                          "Activate",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: primaryColor),
                        ),
                        onPressed: () async {
                          int otherUserId =
                              chatController.chats[widget.index].otherUserId;
                          final ActivateChatModel? activateChatModel =
                              await ChatApis.activateChat(
                            ownerId: otherUserId,
                            conversationId: chatController.currentConvId,
                          );
                          if (activateChatModel == null) {
                            Get.back();
                            Get.snackbar("Activate Chat",
                                "Failed to activate chat, please try again later");
                            return;
                          }
                          Get.back();
                          chatController.chats[widget.index].expiresAt =
                              activateChatModel.expiresAt!;
                          Get.snackbar("Activating Chat",
                              "Chat Reactivated successfully , your new Aqari Points : ${activateChatModel.newPointsBalance}");
                          myPointsController.changeMyPoints(
                              activateChatModel.newPointsBalance);
                          profileController.currentUserInfo!.points =
                              activateChatModel.newPointsBalance.toInt();
                        },
                      ),
                      TextButton(
                        child: Text(
                          "Cancel",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: primaryColorInactive),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
