import 'package:get/get.dart';

class BottomNavigationBarController extends GetxController {
  int selectedIndex = 0;
  bool isSeller = false;
  void changeSelectedIndex({required int index}) {
    selectedIndex = index;

    update();
  }

  void changeIsSeller(bool value) {
    isSeller = value;
    update();
  }

  void clear() {
    selectedIndex = 0;
  }
}
