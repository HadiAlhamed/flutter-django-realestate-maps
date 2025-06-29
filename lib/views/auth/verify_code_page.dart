import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/auth_apis/auth_apis.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/textstyles/text_styles.dart';
import 'package:real_estate/widgets/my_button.dart';
import 'package:real_estate/widgets/my_snackbar.dart';

class VerifyCodePage extends StatelessWidget {
  const VerifyCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 238, 235, 235),
        elevation: 0,
      ),
      body: getVerificationWidgets(context, screenWidth),
    );
  }

  Widget getVerificationWidgets(BuildContext context, double screenWidth) {
    String code = "";

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Code has been sent to ${Api.box.read('email')}",
            style: h3TitleStyleBlack,
            textAlign: TextAlign.center,
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
              code = v;
            },
            onChanged: (value) {
              print(value);
            },
          ),
          const SizedBox(height: 20),
          MyButton(
            title: 'resend code',
            onPressed: () async {
              bool result = await AuthApis.resendActivationCode(
                email: Api.box.read('email'),
              );

              Get.showSnackbar(
                MySnackbar(
                  success: result,
                  title: 'Resend code',
                  message: result
                      ? "Verification code has been resent to your email"
                      : "an error has occurred, please try again later.",
                ),
              );
            },
          ),
          MyButton(
            title: 'Verify',
            onPressed: () async {
              if (code.length != 6) {
                Get.showSnackbar(
                  MySnackbar(
                      success: false,
                      title: 'Email Verification',
                      message: 'please enter the verification code'),
                );
                return;
              }
              bool result = await AuthApis.verifyCode(
                email: Api.box.read('email'),
                code: code,
                purpose: 'activation',
              );
              print("verifing code result : $result");
              if (result) {
                Get.showSnackbar(
                  MySnackbar(
                      success: true,
                      title: 'Email Verification',
                      message: 'Your email is verifed , you can login now'),
                );
                await Future.delayed(
                  const Duration(seconds: 2),
                );
                Get.offAllNamed('/login');
              } else {
                Get.showSnackbar(
                  MySnackbar(
                      success: false,
                      title: 'Email Verification',
                      message:
                          'Invalid code, code expired, or blocked due to too many attempts'),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
