import 'package:get/get.dart';

class SignupController extends GetxController {
  bool isLoading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  void flipIsLoading() {
    isLoading = !isLoading;
    update(['loading']);
  }

  void flipHidePassword() {
    hidePassword = !hidePassword;
    update(['password']);
  }

  void flipHideConfirmPassword() {
    hideConfirmPassword = !hideConfirmPassword;
    update(['confirmPassword']);
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

  void changeHideConfirmPassword(bool value) {
    hidePassword = true;
    update(['confirmPassword']);
  }

  void clear() {
    isLoading = false;
    hidePassword = true;
    hideConfirmPassword = true;
    update(['confirmPassword', 'password']);
  }
}
