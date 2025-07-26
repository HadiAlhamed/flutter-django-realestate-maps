import 'package:get/get.dart';
import 'package:real_estate/controllers/main_controllers/account_page_controller.dart';
import 'package:real_estate/controllers/main_controllers/add_property_controller.dart';
import 'package:real_estate/controllers/main_controllers/bottom_navigation_bar_controller.dart';
import 'package:real_estate/controllers/auth_controllers/change_password_controller.dart';
import 'package:real_estate/controllers/chat_controllers/chat_controller.dart';
import 'package:real_estate/controllers/drop_down_controller.dart';
import 'package:real_estate/controllers/filter_controller.dart';
import 'package:real_estate/controllers/main_controllers/home_page_tab_controller.dart';
import 'package:real_estate/controllers/auth_controllers/login_controller.dart';
import 'package:real_estate/controllers/chat_controllers/message_input_controller.dart';
import 'package:real_estate/controllers/main_controllers/my_map_controller.dart';
import 'package:real_estate/controllers/properties_controllers/my_properties_controller.dart';
import 'package:real_estate/controllers/main_controllers/profile_controller.dart';
import 'package:real_estate/controllers/properties_controllers/property_controller.dart';
import 'package:real_estate/controllers/properties_controllers/property_details_controller.dart';
import 'package:real_estate/controllers/auth_controllers/signup_controller.dart';
import 'package:real_estate/controllers/auth_controllers/forget_password_controller.dart';
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
    Get.put(MyMapController());
    Get.put(ChatController());
    Get.put(MyPropertiesController());
    Get.put(ChangePasswordController());
    Get.put(MessageInputController());
  }
}
