import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:real_estate/services/api.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    // if (kDebugMode) {
    await Api.box.write("access_token", accessToken);
    await Api.box.write("refresh_token", refreshToken);
    // }
  }

  static Future<String?> getAccessToken() async {
    String? accessToken = await _storage.read(key: 'access_token');
    accessToken ??= Api.box.read('access_token');
    return accessToken;
  }

  static Future<String?> getRefreshToken() async {
    String? refreshToken = await _storage.read(key: 'refresh_token');
    refreshToken ??= Api.box.read("refresh_token");
    return refreshToken;
  }

  static Future<void> clearTokens() async {
    await _storage.deleteAll();

    if (Api.box.read('access_token') != null) {
      await Api.box.remove('access_token');
    }
    if (Api.box.read('refresh_token') != null) {
      await Api.box.remove('refresh_token');
    }
  }
}
