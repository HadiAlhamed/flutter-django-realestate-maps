import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  bool emailEntered = false;
  bool codeVerified = false;
  String email = '';
  String code = '';
  bool hidePassword = true;
  bool hideCpassword = true;
  bool isLoading = false;
  void flipHidePassword() {
    hidePassword = !hidePassword;
    update(['password']);
  }

  void changeIsLoading(bool value) {
    isLoading = value;
    update(['loading']);
  }

  void flipHideCpassword() {
    hideCpassword = !hideCpassword;
    update(['cpassword']);
  }

  void changeEmailFlag(bool value) {
    emailEntered = value;
    update(['main']);
  }

  void changeCodeFlag(bool value) {
    codeVerified = value;
    update(['image', 'main']);
  }

  set emailValue(String e) => email = e;

  set codeValue(String c) => code = c;

  void clear() {
    email = '';
    code = '';
    emailEntered = false;
    codeVerified = false;
    isLoading = false;
    update(['password', 'cpassword']);
  }
}
