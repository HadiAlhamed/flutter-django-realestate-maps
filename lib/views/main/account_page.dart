import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/account_page_controller.dart';
import 'package:real_estate/controllers/bottom_navigation_bar_controller.dart';
import 'package:real_estate/controllers/chat_controller.dart';
import 'package:real_estate/controllers/my_properties_controller.dart';
import 'package:real_estate/controllers/profile_controller.dart';
import 'package:real_estate/controllers/property_controller.dart';
import 'package:real_estate/controllers/property_details_controller.dart';
import 'package:real_estate/controllers/theme_controller.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/auth_apis/auth_apis.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/textstyles/text_styles.dart';
import 'package:real_estate/widgets/my_bottom_navigation_bar.dart';
import 'package:real_estate/widgets/my_floating_action_button.dart';
import 'package:real_estate/widgets/my_snackbar.dart';

class AccountPage extends StatelessWidget {
  AccountPage({super.key});
  final AccountPageController accountController =
      Get.find<AccountPageController>();
  final BottomNavigationBarController bottomController =
      Get.find<BottomNavigationBarController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final ThemeController themeController = Get.find<ThemeController>();
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                accountHeader(screenHeight),
                const SizedBox(height: 60),
                GetBuilder<AccountPageController>(
                  id: 'sellerMode',
                  init: accountController,
                  builder: (controller) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      accountController.isSeller ? "Selling" : "Buying",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                getListTiles(),
              ],
            ),
          ),
          getSellerModeSwitch(screenHeight, context)
        ],
      ),
      floatingActionButton: const MyFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: GetBuilder<BottomNavigationBarController>(
        init: bottomController,
        builder: (controller) {
          return MyBottomNavigationBar(
            bottomController: bottomController,
          );
        },
      ),
    );
  }

  Positioned getSellerModeSwitch(double screenHeight, BuildContext context) {
    // Theme.of(context).
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      top: 0.2 * screenHeight - 0.5 * (0.08 * screenHeight),
      left: 20,
      right: 20,
      child: Container(
        height: 0.08 * screenHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: !isDark ? Colors.white : Colors.grey,
        ),
        child: GetBuilder<AccountPageController>(
          id: 'sellerMode',
          init: accountController,
          builder: (controller) => ListTile(
            title: Text(
              "Seller Mode",
              style: isDark ? h2TitleStyleWhite : h2TitleStyleBlack,
            ),
            trailing: getSwitch(
              onChanged: (value) async {
                bool result = await AuthApis.changeIsSeller(value);
                if (result) {
                  accountController.changeIsSeller(value);
                  bottomController.changeIsSeller(value);
                } else {
                  Get.showSnackbar(
                    MySnackbar(
                        success: false,
                        title: "Changing Seller Mode",
                        message: "Failed to change , please try again later."),
                  );
                }
              },
              switchValue: accountController.isSeller,
            ),
          ),
        ),
      ),
    );
  }

  Container accountHeader(double screenHeight) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: primaryColor,
      ),
      height: 0.2 * screenHeight,
      child: ListTile(
        contentPadding: const EdgeInsets.only(top: 60, left: 10, right: 8),
        leading: GetBuilder<ProfileController>(
          id: "profilePhoto",
          init: profileController,
          builder: (controller) => CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(
              profileController.currentUserInfo!.profilePhoto,
            ),
          ),
        ),
        title: GetBuilder<ProfileController>(
          init: profileController,
          id: 'fullName',
          builder: (controller) => Text(
              "${profileController.currentUserInfo?.firstName} ${profileController.currentUserInfo?.lastName}",
              style: h2TitleStyleWhite),
        ),
        trailing:
            const Icon(Icons.notifications, size: 30, color: Colors.white),
      ),
    );
  }

  Column getListTiles() {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: const Icon(Icons.calendar_month),
          title: const Text(
            "My Booking",
          ),
          trailing: const Icon(Icons.keyboard_arrow_right, size: 32),
          onTap: () {},
        ),
        const SizedBox(height: 10),
        GetBuilder(
          init: accountController,
          id: 'sellerMode',
          builder: (controller) => accountController.isSeller
              ? ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  leading: const Icon(Icons.house),
                  title: const Text(
                    "My Properties",
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right, size: 32),
                  onTap: () {
                    Get.toNamed("/myPropertiesPage");
                  },
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: const Icon(Icons.person_2_outlined),
          title: const Text("My Profile"),
          trailing: const Icon(Icons.keyboard_arrow_right, size: 32),
          onTap: () {
            Get.toNamed('/profilePage');
          },
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: const Icon(Icons.password),
          title: const Text("Change Password"),
          trailing: const Icon(Icons.keyboard_arrow_right, size: 32),
          onTap: () {
            Get.toNamed('/changePasswordPage');
          },
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: const Icon(Icons.notifications),
          title: const Text(
            "Notifications",
          ),
          trailing: const Icon(Icons.keyboard_arrow_right, size: 32),
          onTap: () {},
        ),
        const SizedBox(height: 10),
        darkModeSwitch(),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: const Icon(Icons.logout_outlined, color: Colors.red),
          title: const Text("Logout", style: h4TitleStyleRed),
          trailing: const Icon(Icons.keyboard_arrow_right, size: 32),
          onTap: handleLogout,
        ),
      ],
    );
  }

  void handleLogout() async {
    final result = await AuthApis.logout();

    if (result) {
      //remember to clear stuff
      bottomController.clear();

      await Api.box.write('rememberMe', false);

      final ChatController chatController = Get.find<ChatController>();

      final PropertyDetailsController pdController =
          Get.find<PropertyDetailsController>();
      final PropertyController pController = Get.find<PropertyController>();
      final MyPropertiesController myPController =
          Get.find<MyPropertiesController>();
      chatController.clear();
      pdController.clear();
      pController.clear();
      myPController.clear();
      Get.offAllNamed('/login');
    } else {
      Get.showSnackbar(
        MySnackbar(
            success: false,
            title: 'Logout',
            message: 'An error has occurred, please try again later'),
      );
    }
  }

  Obx darkModeSwitch() {
    return Obx(
      () => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        leading: const Icon(Icons.dark_mode_outlined),
        title: const Text(
          "Dark Mode",
        ),
        trailing: getSwitch(
          onChanged: (value) async {
            await themeController.toggleTheme();
          },
          switchValue: themeController.themeMode.value == ThemeMode.dark,
        ),
      ),
    );
  }

  Switch getSwitch({
    required bool switchValue,
    required void Function(bool)? onChanged,
  }) {
    return Switch(
      value: switchValue,
      onChanged: onChanged,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey,
      activeTrackColor: const Color.fromARGB(255, 206, 150, 181),
      activeColor: primaryColor,
    );
  }
}
