import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  bool hideCurrent = true;
  bool hideNew = true;
  bool hideCNew = true;
  bool updateLoading = false;
  void changeIsUpdateLoading(bool value) {
    updateLoading = value;
    update(['updateButton']);
  }

  void flipHideCurrent() {
    hideCurrent = !hideCurrent;
    update(["hideCurrent"]);
  }

  void flipHideNew() {
    hideNew = !hideNew;
    update(["hideNew"]);
  }

  void flipHideCNew() {
    hideCNew = !hideCNew;
    update(["hideCNew"]);
  }

  void clear() {
    hideCurrent = true;
    hideNew = true;
    hideCNew = true;
    updateLoading = false;
  }
}
