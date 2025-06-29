import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_estate/models/profile_info.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/auth_services/auth_interceptor.dart';
import 'package:real_estate/services/auth_services/token_service.dart';

class AuthApis {
  static final Dio _dio = Dio();
  static Future<void> init() async {
    _dio.interceptors.add(AuthInterceptor(_dio));
  }

  static Future<bool> signup({
    required String email,
    required String password,
  }) async {
    print("Email : $email \nPassword : $password");
    try {
      final response = await _dio.post(
        "${Api.baseUrl}/users/signup/",
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 201) {
        print("sign up succeed , check your email");
        return true;
      } else {
        print("sign up failed invalid input data or missing required fields");
        return false;
      }
    } catch (e) {
      print("Network Error : $e");
      return false;
    }
  }

  static Future<int> checkActivationStatus({required String email}) async {
    try {
      final response = await _dio.post(
        "${Api.baseUrl}/users/check-activation-status/",
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        int ret = 0;
        final responseBody = response.data;
        if (responseBody['exists']) {
          ret = 1;
        }
        if (responseBody['is_activated']) {
          ret = 2;
        }
        return ret;
      } else {
        return -1;
      }
    } catch (e) {
      print("Network Error : $e");
      return -1;
    }
  }

  static Future<bool> verifyCode({
    required String email,
    required String code,
    required String purpose,
  }) async {
    print("Email : $email \nCode : $code\nPurpose : $purpose");
    try {
      final response = await _dio.post(
        "${Api.baseUrl}/users/verify-code/",
        data: {
          'email': email,
          'code': code,
          'purpose': purpose,
        },
      );
      print("Hi verifyCode");
      print(response.statusCode);
      print(response.statusMessage);
      print(response.data);

      if (response.statusCode == 200) {
        print(
            "Verification successful, the user is either activated or can now reset their password");
        return true;
      } else if (response.statusCode == 400) {
        print(
            "Invalid code, code expired, or blocked due to too many attempts");
      } else if (response.statusCode == 404) {
        print("User not found or no verification code available for the user");
      }

      return false;
    } catch (e) {
      if (e is DioException) {
        print(e.response?.data);
      }
      print("Network Error : $e");
      return false;
    }
  }

  static Future<bool> resendActivationCode({
    required String email,
  }) async {
    print("Email : $email");
    try {
      final response = await _dio.post(
        "${Api.baseUrl}/users/forgot-password/",
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        print("email verification is resent");
        return true;
      } else {
        print("could not resend email verification");
        return false;
      }
    } catch (e) {
      print("Network Error : $e");
      return false;
    }
  }

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    // TODO: Add login implementation using Dio
    print("Trying to login");
    print("Email : $email \nPassword : $password");
    try {
      final response = await _dio.post(
        "${Api.baseUrl}/users/login/",
        data: {
          'email': email,
          'password': password,
        },
      );
      print("got a resonse");
      if (response.statusCode == 200) {
        final data = response.data;
        print("!!!!access token : ${data['access']}");

        print("!!!!!refresh token : ${data['refresh']}");
        await TokenService.saveTokens(
          accessToken: data['access'],
          refreshToken: data['refresh'],
        );

        print("Login succeed");
        return true;
      } else {
        print("Login unauthorized");
        return false;
      }
    } catch (e) {
      print("Network Error : $e");
      return false;
    }
  }

  static Future<bool> refreshToken() async {
    final refreshToken = await TokenService.getRefreshToken();
    print("refresh token : $refreshToken");
    try {
      final response = await _dio.post(
        '${Api.baseUrl}/auth/jwt/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("tokens refreshed successfully");

        final data = response.data;
        print("new access token : ${data['access']}");

        print("new refresh token : ${data['refresh']}");
        await TokenService.saveTokens(
          accessToken: data['access'],
          refreshToken: data['refresh'],
        );
        return true;
      } else {
        print("tokens failed to refresh !!!");
        print("${response.statusMessage}");
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio Exception : ${e.response?.data}");
      } else {
        print("Network error : $e");
      }
      // await TokenService.clearTokens();
      return false;
    }
  }

  static Future<bool> logout() async {
    // TODO: Add logout implementation if needed
    try {
      final response = await _dio.post(
        '${Api.baseUrl}/users/logout/',
      );
      if (response.statusCode == 200) {
        print("logged out successfully");
        await TokenService.clearTokens();
        return true;
      } else {
        print("logged out failed!!!");
        return false;
      }
    } catch (e) {
      print("Network Error : $e");
      return false;
    }
  }

  static Future<bool> changeIsSeller(bool isSeller) async {
    try {
      final response =
          await _dio.patch('${Api.baseUrl}/users/profile/is-seller/', data: {
        'is_seller': isSeller,
      });
      if (response.statusCode == 200) {
        print("is Seller toggelled successfully");
        return true;
      } else {
        print("is Seller couldn't be toggelled");
        print(response.statusMessage);
        return false;
      }
    } catch (e) {
      print("Network Error : $e");
      return false;
    }
  }

  static Future<bool> setNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        "${Api.baseUrl}/users/set-new-password/",
        data: {
          'email': email,
          'code': code,
          'new_password': newPassword,
        },
      );
      print(response.statusMessage);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Network Error : $e");
      return false;
    }
  }

  static Future<ProfileInfo?> updateProfile({
    String? firstName,
    String? lastName,
    String? gender,
    String? bdate,
    String? country,
    String? phoneNumber,
    XFile? photo, // use File for images
  }) async {
    print("Trying to update profile info");
    print(firstName);
    try {
      final formData = FormData.fromMap({
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (bdate != null) 'birth_date': bdate, // check format: 'YYYY-MM-DD'
        if (country != null) 'country': country,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (gender != null) 'gender': gender,
        if (photo != null) 'photo': await _handleImage(photo),
      });

      final response = await _dio.patch(
        "${Api.baseUrl}/users/profile/",
        data: formData,
      );

      print('✅ Response: ${response.data}');
      if (response.statusCode == 200) {
        return ProfileInfo.fromJson(response.data);
      }
    } catch (e) {
      if (e is DioException) {
        print("❌ Dio error ${e.response?.statusCode}");
        print(
            "❌ Dio error data: ${e.response?.data}"); // 👈 This shows you the backend error
      } else {
        print("❌ General error: $e");
      }
    }
    return null;
  }

  static Future<ProfileInfo?> getProfile() async {
    try {
      print("accessToken  ${await TokenService.getAccessToken()}");
      
      print("refreshToken  ${await TokenService.getRefreshToken()}");
      final response = await _dio.get('${Api.baseUrl}/users/profile/');
      print("HI");
      print(response.statusMessage);
      if (response.statusCode == 200) {
        print(response.data['profile']);
        return ProfileInfo.fromJson(response.data['profile']);
      } else {
        return null;
      }
    } catch (e) {
      if (e is DioException) {
        print(e.response?.statusCode);
        print(e.response?.data);
      } else {
        print("Network Error : $e");
      }
      return null;
    }
  }

  static Future<MultipartFile> _handleImage(XFile photo) async {
    final bytes = await photo.readAsBytes();

    // Prepare MultipartFile from bytes
    final multipartImage = MultipartFile.fromBytes(
      bytes,
      filename: photo.name,
    );
    return multipartImage;
  }
}
