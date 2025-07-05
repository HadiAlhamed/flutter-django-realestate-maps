import 'package:dio/dio.dart';
import 'package:real_estate/models/paginated_conversation.dart';
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
}
