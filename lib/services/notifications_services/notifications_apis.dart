import 'package:dio/dio.dart';
import 'package:real_estate/models/notifications/paginated_notifications.dart';
import 'package:real_estate/services/api.dart';

import 'package:real_estate/services/auth_services/auth_interceptor.dart';

class NotificationsApis {
  static final Dio _dio = Dio();
  static Future<void> init() async {
    _dio.interceptors.add(AuthInterceptor(_dio));
  }

  static Future<PaginatedNotifications> getNotifications({String? url}) async {
    print("fetching notifiations $url");
    try {
      final response = await _dio.get(url ?? "${Api.baseUrl}/notifications/");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        print("notifications :: $data");
        return PaginatedNotifications.fromJson(data);
      }
    } catch (e) {
      if (e is DioException) {
        print(
            "NotificationsApis :: getNotifications :: DioX :: ${e.response?.data}");
      } else {
        print("NotificationsApis :: getNotifications :: NetworkError :: $e");
      }
    }
    return PaginatedNotifications(notifications: [], nextUrl: null);
  }

  static Future<int> getUnreadCount() async {
    print("fetching unread count notifiations ");
    try {
      final response =
          await _dio.get("${Api.baseUrl}/notifications/unread-count/");
      if (response.statusCode == 200) {
        return response.data['unread_count'];
      }
    } catch (e) {
      if (e is DioException) {
        print(
            "NotificationsApis :: getUnreadCount :: DioX :: ${e.response?.data}");
      } else {
        print("NotificationsApis :: getUnreadCount :: NetworkError :: $e");
      }
    }
    return -1;
  }

  static Future<bool> markAllRead() async {
    print("mark all notifiations read");
    try {
      final response =
          await _dio.post("${Api.baseUrl}/notifications/mark-all-read/");
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      if (e is DioException) {
        print(
            "NotificationsApis :: markAllRead :: DioX :: ${e.response?.data}");
      } else {
        print("NotificationsApis :: markAllRead :: NetworkError :: $e");
      }
    }
    return false;
  }

  static Future<bool> markOneRead(int notificationId) async {
    print("mark all notifiations read");
    try {
      final response = await _dio.post(
        "${Api.baseUrl}/notifications/$notificationId/mark-read/",
        data: {'pk': notificationId.toString()},
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      if (e is DioException) {
        print(
            "NotificationsApis :: markOneRead :: DioX :: ${e.response?.data}");
      } else {
        print("NotificationsApis :: markOneRead :: NetworkError :: $e");
      }
    }
    return false;
  }
}
