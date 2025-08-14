import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:real_estate/services/auth_services/auth_apis.dart';
import 'package:real_estate/services/auth_services/token_service.dart';

import '../../controllers/chat_controllers/chat_controller.dart';
import '../../controllers/main_controllers/bottom_navigation_bar_controller.dart';
import '../../controllers/main_controllers/my_points_controller.dart';
import '../../controllers/main_controllers/profile_controller.dart';
import '../../controllers/notifications_controllers/notifications_controller.dart';
import '../../controllers/properties_controllers/my_properties_controller.dart';
import '../../controllers/properties_controllers/property_controller.dart';
import '../../controllers/properties_controllers/property_details_controller.dart';
import '../api.dart';
import '../notifications_services/notifications_webscoket_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  int refreshTokenCounter = 0; // counter for refresh token attempts
  final int maxRefreshAttempts = 10; // threshold
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
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.extra.containsKey('retry')) {
      refreshTokenCounter++;
      final success = await AuthApis.refreshToken();
      if (success) {
        refreshTokenCounter = 0;

        final newToken = await TokenService.getAccessToken();
        final retryRequest = err.requestOptions;

        // Add retry flag
        retryRequest.extra['retry'] = true;

        retryRequest.headers['Authorization'] = 'Bearer $newToken';
        retryRequest.headers['Content-Type'] = 'application/json';

        final response = await dio.fetch(retryRequest);
        return handler.resolve(response);
      } else {
        if (refreshTokenCounter >= maxRefreshAttempts) {
          // Clear tokens and user data
          await TokenService.clearTokens();
          refreshTokenCounter = 0; // reset counter

          return;
        }
      }
    }
    return handler.next(err);
  }

  Future<void> cleanAllData() async {
    //remember to clear stuff

    final BottomNavigationBarController bottomController =
        Get.find<BottomNavigationBarController>();

    final ProfileController profileController = Get.find<ProfileController>();

    final ChatController chatController = Get.find<ChatController>();

    final PropertyDetailsController pdController =
        Get.find<PropertyDetailsController>();

    final PropertyController pController = Get.find<PropertyController>();

    final MyPropertiesController myPController =
        Get.find<MyPropertiesController>();
    final MyPointsController myPointsController =
        Get.find<MyPointsController>();
    final NotificationsController notifController =
        Get.find<NotificationsController>();
    bottomController.clear();

    await Api.box.write('rememberMe', false);

    notifController.clear();
    chatController.clear();
    pdController.clear();
    pController.clear();
    myPController.clear();
    myPointsController.clear();
    profileController.clear();
    NotificationsWebscoketService().disconnectNotificationWebSocket();
    Get.offAllNamed('/login');
  }
}
