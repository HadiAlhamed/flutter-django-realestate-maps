import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_estate/controllers/chat_controllers/chat_controller.dart';
import 'package:real_estate/controllers/chat_controllers/message_input_controller.dart';
import 'package:real_estate/services/chat_services/chat_apis.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:file_picker/file_picker.dart';

class MessageInputBar extends StatefulWidget {
  final double screenHeight;

  const MessageInputBar({super.key, required this.screenHeight});

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _controller = TextEditingController();
  final ChatController chatController = Get.find<ChatController>();
  final MessageInputController messageController =
      Get.find<MessageInputController>();

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
    try {
      print("📤 Uploading image: $imagePath");

      final uploadedUrl = await ChatApis.uploadFile(file: File(imagePath));

      if (uploadedUrl != null) {
        print("✅ Image uploaded. URL: $uploadedUrl");

        chatController.sendMessage(
          conversationId: chatController.currentConvId,
          content: null, // since it's an image
          fileUrl: uploadedUrl,
        );
      } else {
        print("❌ Failed to upload image.");
      }
    } catch (e) {
      print("❌ Exception while uploading image: $e");
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
}
