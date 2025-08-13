import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:real_estate/models/conversations/activate_chat_model.dart';
import 'package:real_estate/models/conversations/chat_status_check.dart';
import 'package:real_estate/models/conversations/conversation.dart';
import 'package:real_estate/models/conversations/message.dart';

import 'package:real_estate/models/conversations/paginated_conversation.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/auth_services/auth_interceptor.dart';

class ChatApis {
  static final Dio _dio = Dio();
  static Future<void> init() async {
    _dio.interceptors.add(AuthInterceptor(_dio));
  }

  static Future<PaginatedConversation> getConversations({String? url}) async {
    print("getConversations :: trying to get conversations...");
    try {
      final response = await _dio.get(
        url ?? "${Api.baseUrl}/chats/conversations/",
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        print("conversations ::$data");

        return PaginatedConversation.fromJson(data);
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio Exception :: getConversations :: ${e.response?.data}");
      } else {
        print("Network Error :: getConversations :: $e");
      }
    }
    return PaginatedConversation(
      conversations: [],
      nextUrl: null,
      totalUnreadCount: 0,
    );
  }

  //change it for paginatedMessage
  static Future<List<Message>> getMessagesFor(int conversationId) async {
    try {
      final response = await _dio.get(
        "${Api.baseUrl}/chats/conversations/$conversationId/messages/",
      );
      if (response.statusCode == 200) {
        final data = response.data;
        print("getMessagesFor data : $data");
        List<Message> messages = (data as List).map((message) {
          return Message.fromJson(message);
        }).toList();
        return messages;
      } else {
        print("getMessagesFor :: failed to fetch messages!!!!");
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio Exception :: getMessagesFor :: ${e.response?.data}");
      } else {
        print("Network Error :: getMessagesFor :: $e");
      }
    }
    return [];
  }

  static Future<bool> updateOnlineStatus(bool isOnline) async {
    try {
      final response = await _dio.patch(
        "${Api.baseUrl}/chats/status/",
        data: {
          'online': isOnline,
        },
      );
      if (response.statusCode == 200) {
        print("updateOnlineStatus :: online status updated successfully");
        return true;
      } else {
        print("updateOnlineStatus :: online status failed to update");
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio Exception :: updateOnlineStatus :: ${e.response?.data}");
      } else {
        print("Network Error :: updateOnlineStatus :: $e");
      }
    }
    return false;
  }

  static Future<int?> createConversation({required String otherUserId}) async {
    print("trying to create a conversation with $otherUserId");
    try {
      final response = await _dio.post(
        "${Api.baseUrl}/chats/conversations/create/",
        data: {
          'other_user_id': otherUserId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(
            "createConversation :: conversation already exists or created successfully...");
        final data = response.data;
        return data['id'];
      } else {
        print("createConversation :: failed to create new conversation");
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio Exception :: createConversation :: ${e.response?.data}");
      } else {
        print("Network Error :: createConversation :: $e");
      }
    }
    return -1;
  }

  static Future<String?> uploadFile({required File file}) async {
    print("uploadFile :: trying to upload an File .... ");
    print("image extension : ${path.extension(file.path).toLowerCase()}");
    final mimeType = lookupMimeType(file.path); // e.g. "image/jpeg"
    print("mime type of file : $mimeType");
    final String fileName = file.path.split('/').last;
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType!), // ✅ very important
        ),
      });
      final response = await _dio.post(
        "${Api.baseUrl}/chats/files/upload/",
        data: formData,
      );
      if (response.statusCode == 201) {
        return response.data['file_url'] as String;
      } else {
        print("uploadFile :: Failed to upload File");
      }
    } catch (e) {
      if (e is DioException) {
        print("uploadFile :: DioException :: ${e.response?.data}");
      } else {
        print("uploadFile :: networkError :: $e");
      }
    }
    return null;
  }

  static Future<XFile?> compressImage(File file) async {
    final originalExtension = path.extension(file.path); // e.g., .png, .jpg

    final dir = await getTemporaryDirectory();
    final targetPath = path.join(
        dir.path, "${DateTime.now().millisecondsSinceEpoch}$originalExtension");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // Try 60–80 for good balance
    );

    return result;
  }

  static Future<void> openRemoteFile(String fileUrl) async {
    print("openRemoteFile :: Trying to open remote file (pdf file)");
    try {
      final dir = await getTemporaryDirectory();
      final fileName = fileUrl.split('/').last;
      final filePath =
          "${dir.path}/${DateTime.now().microsecondsSinceEpoch}/$fileName";
      final response = await _dio.download(fileUrl, filePath);
      if (response.statusCode == 200) {
        await OpenFilex.open(filePath);
      } else {
        print("chatApis :: openRemoteFile :: failed to open remote file");
      }
    } catch (e) {
      if (e is DioException) {
        print(
            "chatApis :: openRemoteFile :: DioException :: ${e.response?.data}");
      } else {
        print("chatApis :: openRemoteFile :: NetworkE Error :: $e");
      }
    }
  }

  static Future<ChatStatusCheck?> checkStatus({required int propertyId}) async {
    try {
      final response = await _dio.get(
        "${Api.baseUrl}/chats/conversations/check-status/$propertyId/",
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        debugPrint("ChatApis :: checkStatus :: result :: $data");
        return ChatStatusCheck.fromJson(data);
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint("ChatApis :: checkStatus :: DioX :: ${e.response?.data}");
      } else {
        debugPrint("ChatApis :: checkStatus :: General Error :: $e");
      }
    }
    return null;
  }

  static Future<ActivateChatModel?> activateChat({
    required int propertyId,
    int? conversationId,
  }) async {
    try {
      final response = await _dio.post(
        "${Api.baseUrl}/chats/conversations/activate/",
        data: {
          'property_id': propertyId,
          if (conversationId != null) 'conversation_id': conversationId,
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        debugPrint("ChatApis :: activateChat :: result :: $data");
        return ActivateChatModel.fromJson(data);
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint("ChatApis :: activateChat :: DioX :: ${e.response?.data}");
      } else {
        debugPrint("ChatApis :: activateChat :: General Error :: $e");
      }
    }
    return null;
  }

  static Future<Conversation?> getConversation({
    required int conversationId,
  }) async {
    try {
      final response = await _dio.get(
        "${Api.baseUrl}/chats/conversations/$conversationId/info/",
        data: {
          'pk': conversationId,
          'id ': conversationId.toString(),
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        debugPrint("ChatApis :: getConversation :: result :: $data");
        return Conversation.fromJson(data);
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint(
            "ChatApis :: getConversation :: DioX :: ${e.response?.data}");
      } else {
        debugPrint("ChatApis :: getConversation :: General Error :: $e");
      }
    }
    return null;
  }
}
