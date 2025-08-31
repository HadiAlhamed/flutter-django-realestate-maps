import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/auth_controllers/signup_controller.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/auth_services/auth_apis.dart';
import 'package:real_estate/textstyles/text_styles.dart';
import 'package:real_estate/widgets/general_widgets/my_button.dart';
import 'package:real_estate/widgets/general_widgets/my_input_field.dart';
import 'package:real_estate/widgets/general_widgets/my_row_button.dart';
import 'package:real_estate/widgets/general_widgets/my_snackbar.dart';

class Signup extends StatelessWidget {
  Signup({super.key});
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  final SignupController signupController = Get.find<SignupController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                margin: EdgeInsets.only(top: screenHeight * 0.2, bottom: 20),
                height: 200,
                child: Image.asset(
                  "assets/images/Aqari_logo_primary_towers.png",
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const Text("Create New Account", style: h1TitleStyleBlack),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Form(
                  key: formState,
                  child: Column(
                    children: [
                      MyInputField(
                        validator: (value) {
                          if (value == null || value == '') {
                            return "please enter your email";
                          }
                          return null;
                        },
                        controller: emailController,
                        hint: 'Email',
                        prefixIcon: Icons.email,
                      ),
                      GetBuilder<SignupController>(
                        id: 'password',
                        init: signupController,
                        builder: (controller) {
                          return MyInputField(
                            validator: (value) {
                              if (value == null || value == '') {
                                return "please enter your password";
                              }
                              return null;
                            },
                            controller: passwordController,
                            hint: 'Password',
                            prefixIcon: Icons.password,
                            isObsecure: signupController.hidePassword,
                            suffixWidget: IconButton(
                              onPressed: () =>
                                  signupController.flipHidePassword(),
                              icon: Icon(
                                signupController.hidePassword
                                    ? Icons.remove_red_eye_outlined
                                    : Icons.remove_red_eye,
                              ),
                            ),
                          );
                        },
                      ),
                      GetBuilder<SignupController>(
                        id: 'confirmPassword',
                        init: signupController,
                        builder: (controller) {
                          return MyInputField(
                            validator: (value) {
                              if (value == null || value == '') {
                                return "please confirm your password";
                              }
                              if (value != passwordController.text) {
                                return "Passwords do not match.";
                              }
                              return null;
                            },
                            controller: cPasswordController,
                            hint: 'Confirm Password',
                            prefixIcon: Icons.password,
                            isObsecure: signupController.hideConfirmPassword,
                            suffixWidget: IconButton(
                              onPressed: () =>
                                  signupController.flipHideConfirmPassword(),
                              icon: Icon(
                                signupController.hideConfirmPassword
                                    ? Icons.remove_red_eye_outlined
                                    : Icons.remove_red_eye,
                              ),
                            ),
                          );
                        },
                      ),
                      GetBuilder(
                        id: 'loading',
                        init: signupController,
                        builder: (controller) {
                          return MyButton(
                            onPressed: handleSignUp,
                            title:
                                signupController.isLoading ? null : 'Sign Up',
                          );
                        },
                      ),
                      GetBuilder<SignupController>(
                        id: 'loadingGoogle',
                        init: signupController,
                        builder: (controller) {
                          return MyRowButton(
                            onPressed: () async {
                              signupController.changeIsLoadingGoogle(true);
                              await Future.delayed(
                                const Duration(
                                  seconds: 3,
                                ),
                              );
                              signupController.changeIsLoadingGoogle(false);
                            },
                            child: signupController.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Sign up with ",
                                        style: buttonTextStyleWhite,
                                      ),
                                      SizedBox(
                                        height: 30,
                                        child: Image.asset(
                                            'assets/images/logos/google_logo.png'),
                                      ),
                                    ],
                                  ),
                          );
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: h4TitleStyleGrey,
                            ),
                            InkWell(
                              onTap: () {
                                Get.offNamed('/login');
                              },
                              child: const Text(
                                "Login",
                                style: h3TitleStylePrimary,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleSignUp() async {
    if (formState.currentState!.validate()) {
      signupController.changeIsLoading(true);
      final int activationResult = await AuthApis.checkActivationStatus(
        email: emailController.text.trim(),
      );
      print(activationResult);
      if (activationResult == -1) {
        Get.showSnackbar(
          MySnackbar(
            success: false,
            title: "Signing up",
            message: 'An error has occurred please try again later',
          ),
        );
      } else if (activationResult <= 1) {
        //new email
        final bool result = activationResult == 1
            ? true
            : await AuthApis.signup(
                email: emailController.text.trim(),
                password: passwordController.text,
              );
        if (result) {
          await Future.wait([
            Api.box.write('email', emailController.text.trim()),
            Api.box.write('password', passwordController.text)
          ]);

          //go to code page
          Get.toNamed('/verifyCodePage');
        } else {
          //show error message
          Get.showSnackbar(
            MySnackbar(
              success: false,
              title: "Signing up",
              message: 'An error has occurred please try again later',
            ),
          );
        }
      } else {
        //activationResult = 2
        Get.showSnackbar(
          MySnackbar(
            success: false,
            title: "Signing up",
            message: 'Email already exits.',
          ),
        );
      }
      signupController.changeIsLoading(false);
    }
  }
}
