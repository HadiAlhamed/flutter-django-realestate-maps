import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/bottom_navigation_bar_controller.dart';
import 'package:real_estate/controllers/change_password_controller.dart';
import 'package:real_estate/controllers/chat_controller.dart';
import 'package:real_estate/controllers/my_properties_controller.dart';
import 'package:real_estate/controllers/property_controller.dart';
import 'package:real_estate/controllers/property_details_controller.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/auth_apis/auth_apis.dart';
import 'package:real_estate/services/auth_services/token_service.dart';
import 'package:real_estate/widgets/my_button.dart';
import 'package:real_estate/widgets/my_input_field.dart';
import 'package:real_estate/widgets/my_snackbar.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final ChangePasswordController changePController =
      Get.find<ChangePasswordController>();

  final TextEditingController currentController = TextEditingController();

  final TextEditingController newController = TextEditingController();

  final TextEditingController confirmController = TextEditingController();
  @override
  dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: getNewPasswordWidgets(),
      ),
    );
  }

  SingleChildScrollView getNewPasswordWidgets() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset(
            'assets/gifs/Forgot_password_1_transparent.gif',
          ),
          const SizedBox(height: 20),
          GetBuilder<ChangePasswordController>(
            init: changePController,
            id: 'hideCurrent',
            builder: (controller) => MyInputField(
              hint: 'Current Password',
              controller: currentController,
              prefixIcon: Icons.password,
              isObsecure: changePController.hideCurrent,
              suffixWidget: IconButton(
                onPressed: () {
                  changePController.flipHideCurrent();
                },
                icon: Icon(
                  changePController.hideCurrent
                      ? Icons.remove_red_eye_outlined
                      : Icons.remove_red_eye,
                ),
              ),
            ),
          ),
          GetBuilder<ChangePasswordController>(
            init: changePController,
            id: 'hideNew',
            builder: (controller) => MyInputField(
              hint: 'New Password',
              controller: newController,
              prefixIcon: Icons.password,
              isObsecure: changePController.hideNew,
              suffixWidget: IconButton(
                onPressed: () {
                  changePController.flipHideNew();
                },
                icon: Icon(
                  changePController.hideNew
                      ? Icons.remove_red_eye_outlined
                      : Icons.remove_red_eye,
                ),
              ),
            ),
          ),
          GetBuilder<ChangePasswordController>(
            init: changePController,
            id: 'hideCNew',
            builder: (controller) => MyInputField(
              hint: 'Confirm Password',
              controller: confirmController,
              prefixIcon: Icons.password,
              isObsecure: changePController.hideCNew,
              suffixWidget: IconButton(
                onPressed: () {
                  changePController.flipHideCNew();
                },
                icon: Icon(
                  changePController.hideCNew
                      ? Icons.remove_red_eye_outlined
                      : Icons.remove_red_eye,
                ),
              ),
            ),
          ),
          GetBuilder<ChangePasswordController>(
            init: changePController,
            id: "updateButton",
            builder: (controller) => MyButton(
              title: changePController.updateLoading ? null : "Update",
              onPressed: () async {
                if (newController.text.isEmpty ||
                    newController.text.trim() !=
                        confirmController.text.trim()) {
                  Get.showSnackbar(
                    MySnackbar(
                      success: false,
                      title: "New Password",
                      message: 'Passwords do not match',
                    ),
                  );
                  return;
                }
                changePController.changeIsUpdateLoading(true);
                bool result = await AuthApis.changePassword(
                  currentPassword: currentController.text.trim(),
                  newPassword: newController.text.trim(),
                );
                changePController.changeIsUpdateLoading(false);

                if (result) {
                  TokenService.clearTokens();
                  changePController.clear();

                  await Api.box.write('rememberMe', false);

                  final ChatController chatController =
                      Get.find<ChatController>();

                  final PropertyDetailsController pdController =
                      Get.find<PropertyDetailsController>();
                  final PropertyController pController =
                      Get.find<PropertyController>();
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
                      title: 'Update Password',
                      message:
                          'Failed to update new password please try again later.',
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
