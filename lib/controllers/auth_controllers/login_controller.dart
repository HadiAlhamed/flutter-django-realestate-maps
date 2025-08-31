import 'package:get/get.dart';

class LoginController extends GetxController {
  bool isLoading = false;
  bool hidePassword = true;
  bool rememberMe = false;
  void flipRememberMe(bool? value) {
    rememberMe = value ?? !rememberMe;
    update(['rememberMe']);
  }

  void flipIsLoading() {
    isLoading = !isLoading;
    update(['loading']);
  }

  void flipHidePassword() {
    hidePassword = !hidePassword;
    update(['password']);
  }

  void changeIsLoading(bool value) {
    isLoading = value;
    update(['loading']);
  }

  void changeIsLoadingGoogle(bool value) {
    isLoading = value;
    update(['loadingGoogle']);
  }

  void changeHidePassword(bool value) {
    hidePassword = true;
    update(['password']);
  }

  void clear() {
    isLoading = false;
    hidePassword = true;
    update(['password']);
  }
}
