import 'package:get/get.dart';

class AccountPageController extends GetxController {
  bool isSeller = false;
  void changeIsSeller(bool value) {
    isSeller = value;
    update(['sellerMode']);
  }
}
