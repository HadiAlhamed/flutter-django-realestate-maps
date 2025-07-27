import 'package:dio/dio.dart';

import 'package:real_estate/services/auth_services/auth_interceptor.dart';

class NotificationsApis {
  static final Dio _dio = Dio();
  static Future<void> init() async {
    _dio.interceptors.add(AuthInterceptor(_dio));
  }
}
