import 'package:dio/dio.dart';
import 'package:real_estate/services/auth_apis/auth_apis.dart';
import 'package:real_estate/services/auth_services/token_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenService.getAccessToken();
    print("Access token is : $token");
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      options.headers['Content-Type'] = 'application/json';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      print("dio got an 401 error!!!");
      final success = await AuthApis.refreshToken();
      if (success) {
        final newToken = await TokenService.getAccessToken();

        // Retry original request with new token
        final retryRequest = err.requestOptions;
        retryRequest.headers['Authorization'] = 'Bearer $newToken';
        retryRequest.headers['Content-Type'] = 'application/json';

        final response = await dio.fetch(retryRequest);
        return handler.resolve(response);
      }
    }
    return handler.next(err);
  }
}
