import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/main_controllers/my_points_controller.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/widgets/general_widgets/my_button.dart';
import 'package:real_estate/widgets/general_widgets/my_input_field.dart';

class MyPointsPage extends StatelessWidget {
  MyPointsPage({super.key});
  final MyPointsController myPointsController = Get.find<MyPointsController>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController dollarValueController = TextEditingController();
  final TextEditingController pointsValueController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black45
            : const Color.fromARGB(133, 205, 175, 192),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.black45
                      : const Color.fromARGB(133, 205, 175, 192),
                  primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //points
                  _getGlassyContainer(
                    context: context,
                    child: GetBuilder<MyPointsController>(
                      id: "points",
                      init: myPointsController,
                      builder: (controller) {
                        return Text(
                          "${controller.myPoints}",
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontSize: 30,
                                  ),
                        );
                      },
                    ),
                  ),
                  //purchase points button
                  _getGlassyContainer(
                    context: context,
                    child: TextButton(
                      onPressed: () {
                        Get.bottomSheet(
                          Container(
                            constraints:
                                BoxConstraints(maxHeight: screenHeight * 0.7),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 20),
                            child: SingleChildScrollView(
                              child: Form(
                                key: formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Choose Payment Method",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    GetBuilder<MyPointsController>(
                                      id: "paymentMethods",
                                      init: myPointsController,
                                      builder: (controller) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _getPaymentMethodOption(
                                              assetUrl:
                                                  'assets/images/logos/alBarakaLogo.png',
                                              index: 0,
                                            ),
                                            _getPaymentMethodOption(
                                              index: 1,
                                              assetUrl:
                                                  'assets/images/logos/bemoLogo.jpg',
                                            ),
                                            _getPaymentMethodOption(
                                              index: 2,
                                              assetUrl:
                                                  'assets/images/logos/paypalLogo.png',
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    paymentField(
                                      hint: "Enter Card Number",
                                      controller: cardNumberController,
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please Enter Your Credit Card Number";
                                        }
                                        if (value.length != 16) {
                                          return "Credit Card Number Must Be More Than 16 digits";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: paymentField(
                                            hint: "Amount",
                                            controller: dollarValueController,
                                            suffixWidget: Icon(
                                              Icons.attach_money_outlined,
                                            ),
                                            onChanged: (value) {
                                              if (value.isEmpty) return;
                                              int dollarValue = int.parse(
                                                  dollarValueController.text);
                                              pointsValueController.text =
                                                  (dollarValue * 100)
                                                      .toString();
                                            },
                                            validator: (String? value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Please Enter Exchange Amount";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: paymentField(
                                            hint: "Aqari points",
                                            controller: pointsValueController,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    GetBuilder<MyPointsController>(
                                      id: "hidePassword",
                                      init: myPointsController,
                                      builder: (controller) => paymentField(
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please Enter Your Password";
                                          }
                                          return null;
                                        },
                                        isObsecure:
                                            myPointsController.hidePassword,
                                        hint: "Enter Your Password",
                                        controller: passwordController,
                                        suffixWidget: IconButton(
                                          onPressed: () {
                                            myPointsController
                                                .flipHidePassword(null);
                                          },
                                          icon: Icon(
                                            myPointsController.hidePassword
                                                ? Icons.remove_red_eye_outlined
                                                : Icons.remove_red_eye,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    MyButton(
                                      title: "Submit",
                                      onPressed: () async {
                                        if (!formKey.currentState!.validate()) {
                                          return;
                                        }
                                        await myPointsController.chargePoints(
                                          bankName: _getBankName(),
                                          creditCardNumber:
                                              cardNumberController.text.trim(),
                                          password:
                                              passwordController.text.trim(),
                                          amount:
                                              dollarValueController.text.trim(),
                                        );
                                        passwordController.clear();
                                        cardNumberController.clear();
                                        dollarValueController.clear();
                                        pointsValueController.clear();
                                        myPointsController
                                            .flipHidePassword(true);
                                        Get.back();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black54
                                  : Colors.white,
                        );
                      },
                      child: Text(
                        "Purchase Points",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  MyInputField paymentField({
    required String hint,
    Widget? suffixWidget,
    Widget? prefixWidget,
    TextEditingController? controller,
    bool? readOnly,
    void Function()? ontap,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool? isObsecure,
  }) {
    return MyInputField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      prefixWidget: prefixWidget,
      ontap: ontap,
      readOnly: readOnly,
      controller: controller,
      suffixWidget: suffixWidget,
      hint: hint,
      borderSide: BorderSide.none,
      validator: validator,
      isObsecure: isObsecure,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  InkWell _getPaymentMethodOption({
    required int index,
    required String assetUrl,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () {
        myPointsController.changeChosenPayment(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 100,
        height: 100, // ✅ same as width to keep shape perfectly circular
        alignment: Alignment.center, // ✅ centers the text
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: myPointsController.chosenPayment != index
              ? null
              : Border.all(
                  color: primaryColor,
                  width: 5,
                ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            assetUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _getGlassyContainer({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16), // Inner padding

              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withAlpha((0.05 * 255).round())
                    : Colors.white.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withAlpha((0.15 * 255).round()),
                ),
              ),
              child: child,
            ),
          ),
        ));
  }

  String _getBankName() {
    int index = myPointsController.chosenPayment;
    if (index == 0) {
      return 'Albarakeh bank';
    } else if (index == 1) {
      return 'Pemo bank';
    } else {
      return 'PayPal';
    }
  }
}
