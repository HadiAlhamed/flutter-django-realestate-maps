import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:real_estate/controllers/forget_password_controller.dart';
import 'package:real_estate/services/auth_apis/auth_apis.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/textstyles/text_styles.dart';
import 'package:real_estate/widgets/my_button.dart';
import 'package:real_estate/widgets/my_input_field.dart';
import 'package:real_estate/widgets/my_snackbar.dart';

class ForgetPasswordPage extends StatelessWidget {
  ForgetPasswordPage({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cpasswordController = TextEditingController();
  final ForgetPasswordController fpController =
      Get.find<ForgetPasswordController>();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forget Password"),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 40, left: 10, right: 10, bottom: 4),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GetBuilder<ForgetPasswordController>(
                init: fpController,
                id: 'image',
                builder: (controller) => Image.asset(!fpController.codeVerified
                    ? 'assets/gifs/Forgot_password_transparent.gif'
                    : 'assets/gifs/Forgot_password_1_transparent.gif'),
              ),
              const SizedBox(height: 20),
              GetBuilder<ForgetPasswordController>(
                init: fpController,
                id: 'main',
                builder: (controller) {
                  if (!fpController.emailEntered) {
                    return getEmailWidgets();
                  }
                  if (!fpController.codeVerified) {
                    return getVerificationWidgets(context, screenWidth);
                  }
                  return getNewPasswordWidgets();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column getNewPasswordWidgets() {
    return Column(
      children: [
        GetBuilder<ForgetPasswordController>(
          init: fpController,
          id: 'password',
          builder: (controller) => MyInputField(
            hint: 'New password',
            controller: passwordController,
            prefixIcon: Icons.password,
            isObsecure: fpController.hidePassword,
            suffixWidget: IconButton(
              onPressed: () {
                fpController.flipHidePassword();
              },
              icon: Icon(
                fpController.hidePassword
                    ? Icons.remove_red_eye_outlined
                    : Icons.remove_red_eye,
              ),
            ),
          ),
        ),
        GetBuilder<ForgetPasswordController>(
          init: fpController,
          id: 'cpassword',
          builder: (controller) => MyInputField(
            hint: 'Confirm password',
            controller: cpasswordController,
            prefixIcon: Icons.password,
            isObsecure: fpController.hideCpassword,
            suffixWidget: IconButton(
              onPressed: () {
                fpController.flipHideCpassword();
              },
              icon: Icon(
                fpController.hideCpassword
                    ? Icons.remove_red_eye_outlined
                    : Icons.remove_red_eye,
              ),
            ),
          ),
        ),
        GetBuilder<ForgetPasswordController>(
          init: fpController,
          id: "loading",
          builder: (controller) => MyButton(
            title: fpController.isLoading ? null : "Continue",
            onPressed: () async {
              if (passwordController.text != cpasswordController.text) {
                Get.showSnackbar(
                  MySnackbar(
                    success: false,
                    title: "New Password",
                    message: 'Passwords does not match',
                  ),
                );
                return;
              }
              fpController.changeIsLoading(true);
              bool result = await AuthApis.setNewPassword(
                email: fpController.email,
                code: fpController.code,
                newPassword: passwordController.text,
              );
              fpController.changeIsLoading(false);

              if (result) {
                fpController.clear();
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
    );
  }

  Column getVerificationWidgets(BuildContext context, double screenWidth) {
    return Column(
      children: [
        Text(
          "Code has been sent to ${fpController.email}",
          style: h3TitleStyleBlack,
        ),
        const SizedBox(height: 20),
        PinCodeTextField(
          appContext: context,
          length: 6,
          obscureText: false,
          animationType: AnimationType.fade,
          keyboardType: TextInputType.number,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(5),
            fieldHeight: 50,
            fieldWidth: screenWidth / 8,
            inactiveFillColor: Colors.white,
            activeFillColor: Colors.white,
            inactiveColor: primaryColor,
          ),
          animationDuration: const Duration(milliseconds: 300),
          onCompleted: (v) {
            print("Completed: $v");
            //code to verify = v
            fpController.codeValue = v;
          },
          onChanged: (value) {
            print(value);
          },
        ),
        const SizedBox(height: 20),
        GetBuilder(
          init: fpController,
          id: "loading",
          builder: (controller) => MyButton(
            title: fpController.isLoading ? null : 'Verify',
            onPressed: () async {
              fpController.changeIsLoading(true);
              bool result = await AuthApis.verifyCode(
                email: fpController.email,
                code: fpController.code,
                purpose: 'password_reset',
              );
              fpController.changeIsLoading(false);

              if (result) {
                fpController.changeCodeFlag(true);
              } else {
                Get.showSnackbar(
                  MySnackbar(
                      success: false,
                      title: "Verify Code",
                      message:
                          'Failed to verify the code , please make sure you are using the right code and try again later.'),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Column getEmailWidgets() {
    return Column(
      children: [
        const Text(
          "Please enter your email to receive a verification code",
          style: h3TitleStyleBlack,
        ),
        const SizedBox(height: 20),
        MyInputField(
          hint: 'Email',
          controller: emailController,
        ),
        GetBuilder<ForgetPasswordController>(
          init: fpController,
          id: 'loading',
          builder: (controller) => MyButton(
            title: fpController.isLoading ? null : 'Continue',
            onPressed: () async {
              if (emailController.text == '') {
                //later add a snackbar telling the user to give an email
                Get.showSnackbar(
                  MySnackbar(
                    success: false,
                    title: 'Email',
                    message: "Enter your email please",
                  ),
                );
                return;
              }
              //store the email for the post api

              fpController.emailValue = emailController.text.trim();
              fpController.changeIsLoading(true);
              bool result = await AuthApis.resendActivationCode(
                  email: emailController.text.trim());
              fpController.changeIsLoading(false);
              if (result) {
                fpController.changeEmailFlag(true);
              } else {
                Get.showSnackbar(
                  MySnackbar(
                      success: false,
                      title: "Code Verification",
                      message:
                          'Failed to send a code verification to your email , please try again later'),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
