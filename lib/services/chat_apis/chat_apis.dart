import 'package:dio/dio.dart';
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
    return PaginatedConversation(conversations: [], nextUrl: null);
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
}
