import 'package:get/get.dart';
import 'package:real_estate/controllers/account_page_controller.dart';
import 'package:real_estate/controllers/add_property_controller.dart';
import 'package:real_estate/controllers/bottom_navigation_bar_controller.dart';
import 'package:real_estate/controllers/drop_down_controller.dart';
import 'package:real_estate/controllers/filter_controller.dart';
import 'package:real_estate/controllers/home_page_tab_controller.dart';
import 'package:real_estate/controllers/login_controller.dart';
import 'package:real_estate/controllers/profile_controller.dart';
import 'package:real_estate/controllers/property_controller.dart';
import 'package:real_estate/controllers/property_details_controller.dart';
import 'package:real_estate/controllers/signup_controller.dart';
import 'package:real_estate/controllers/forget_password_controller.dart';
import 'package:real_estate/controllers/theme_controller.dart';

class MyBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(LoginController());
    Get.put(SignupController());
    Get.put(BottomNavigationBarController());
    Get.put(HomePageTabController());
    Get.put(DropDownController());
    Get.put(ForgetPasswordController());
    Get.put(AccountPageController());
    Get.put(AddPropertyController());
    Get.put(PropertyController());
    Get.put(PropertyDetailsController());
    Get.put(ProfileController());
    Get.put(ThemeController());
    Get.put(FilterController());
  }
}
