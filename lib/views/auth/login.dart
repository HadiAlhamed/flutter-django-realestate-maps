import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/login_controller.dart';
import 'package:real_estate/controllers/profile_controller.dart';
import 'package:real_estate/models/profile_info.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/auth_apis/auth_apis.dart';
import 'package:real_estate/textstyles/text_styles.dart';
import 'package:real_estate/widgets/my_button.dart';
import 'package:real_estate/widgets/my_input_field.dart';
import 'package:real_estate/widgets/my_row_button.dart';
import 'package:real_estate/widgets/my_snackbar.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  final LoginController loginController = Get.find<LoginController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ProfileController profileController = Get.find<ProfileController>();
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
              const Text("Login To Your Account", style: h1TitleStyleBlack),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Form(
                  key: formState,
                  child: Column(
                    children: [
                      MyInputField(
                        controller: emailController,
                        hint: 'Email',
                        prefixIcon: Icons.email,
                      ),
                      GetBuilder<LoginController>(
                        id: 'password',
                        init: loginController,
                        builder: (controller) {
                          return MyInputField(
                            controller: passwordController,
                            hint: 'Password',
                            prefixIcon: Icons.password,
                            isObsecure: loginController.hidePassword,
                            suffixWidget: IconButton(
                              onPressed: () {
                                loginController.flipHidePassword();
                              },
                              icon: Icon(
                                loginController.hidePassword
                                    ? Icons.remove_red_eye_outlined
                                    : Icons.remove_red_eye,
                              ),
                            ),
                          );
                        },
                      ),
                      GetBuilder<LoginController>(
                        id: 'rememberMe',
                        init: loginController,
                        builder: (controller) {
                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Remember Me",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Checkbox(
                                  value: loginController.rememberMe,
                                  onChanged: (value) {
                                    loginController.flipRememberMe(value);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      GetBuilder<LoginController>(
                        id: 'loading',
                        init: loginController,
                        builder: (controller) {
                          return MyButton(
                            title: loginController.isLoading ? null : 'Sign In',
                            onPressed: handleLogin,
                          );
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed('/forgetPassword');
                          },
                          child: const Text(
                            "Forget Password?",
                            style: h3TitleStylePrimary,
                          ),
                        ),
                      ),
                      GetBuilder<LoginController>(
                        id: 'loadingGoogle',
                        init: loginController,
                        builder: (controller) {
                          return MyRowButton(
                            onPressed: () async {
                              loginController.changeIsLoadingGoogle(true);
                              await Future.delayed(
                                const Duration(seconds: 3),
                              );
                              loginController.changeIsLoadingGoogle(false);
                            },
                            child: loginController.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Sign in with ",
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
                              "Doesn't have an account? ",
                              style: h4TitleStyleGrey,
                            ),
                            InkWell(
                              onTap: () {
                                Get.offNamed('/signup');
                              },
                              child: const Text(
                                "register now",
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

  void handleLogin() async {
    if (formState.currentState!.validate()) {
      loginController.changeIsLoading(true);
      bool result = await AuthApis.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (result) {
        ProfileInfo? userInfo = await AuthApis.getProfile();
        loginController.clear();
        await Api.box.write('rememberMe', loginController.rememberMe);
        if (userInfo != null) {
          //store user info in box
          profileController.changeCurrentUserInfo(userInfo);
          Get.offNamed('/home');
          
        } else {
          Get.toNamed('/profilePage', arguments: {'isNew': true});
          //if new store it in the profile page
        }
      } else {
        Get.showSnackbar(
          MySnackbar(
            success: false,
            title: "Login",
            message: 'Failed to login , please try again later',
          ),
        );
      }

      loginController.changeIsLoading(false);
    }
  }
}
