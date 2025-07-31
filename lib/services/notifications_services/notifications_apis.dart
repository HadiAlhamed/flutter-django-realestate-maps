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
      final response = await _dio.get("${Api.baseUrl}/notifications/");
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
}
