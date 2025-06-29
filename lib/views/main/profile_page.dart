import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_estate/controllers/drop_down_controller.dart';
import 'package:real_estate/controllers/profile_controller.dart';
import 'package:real_estate/models/profile_info.dart';
import 'package:real_estate/services/auth_apis/auth_apis.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/widgets/my_button.dart';
import 'package:real_estate/widgets/my_input_field.dart';
import 'package:intl/intl.dart';
import 'package:real_estate/widgets/my_snackbar.dart';

class ProfilePage extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final DropDownController dropDownController = Get.find<DropDownController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final ImagePicker imagePicker = ImagePicker();
  XFile? profilePhoto;
  final args = Get.arguments;
  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isNew = args?['isNew'] ?? false;

    emailController.text = 'example@gmail.com';
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: const Text(
          "Profile",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Divider(
                thickness: 2,
              ),
              GetBuilder<ProfileController>(
                init: profileController,
                id: "profilePhoto",
                builder: (controller) {
                  return CircleAvatar(
                    radius: screenWidth * 0.3,
                    backgroundImage: profileController.profilePhoto != null
                        ? FileImage(
                            File(profileController.profilePhoto!.path),
                          )
                        : const AssetImage(
                            'assets/images/Aqari_logo_primary_towers.png'),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        onPressed: () async {
                          profilePhoto = await imagePicker.pickImage(
                              source: ImageSource.gallery);
                          if (profilePhoto != null) {
                            profileController.changeProfilePhoto(profilePhoto!);
                          }
                        },
                        icon: const Icon(
                          Icons.auto_fix_high,
                          color: primaryColor,
                          size: 25,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              myProfileInput(
                hint: 'First Name',
                controller: firstNameController,
              ),
              myProfileInput(hint: 'Last Name', controller: lastNameController),
              myProfileInput(
                  hint: 'Email', controller: emailController, readOnly: true),
              myProfileInput(
                readOnly: true,
                controller: birthDateController,
                hint: 'date of birth',
                suffixWidget: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    DateTime? chosenBirthDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      currentDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (chosenBirthDate != null) {
                      String formatedDate =
                          DateFormat('yyyy-MM-dd').format(chosenBirthDate);
                      birthDateController.text = formatedDate;
                    }
                  },
                ),
              ),
              genderDropDownMenu(),
              const SizedBox(height: 20),
              myProfileInput(
                hint: 'Country',
                controller: countryController,
                suffixWidget: const Icon(Icons.arrow_drop_down),
                readOnly: true,
                ontap: () {
                  print("HI");
                  showCountryPicker(
                    context: context,
                    onSelect: (Country country) {
                      countryController.text =
                          "${country.flagEmoji} ${country.name}";
                    },
                  );
                },
              ),
              myProfileInput(
                hint: 'Phone number',
                keyboardType: TextInputType.phone,
                controller: phoneController,
                prefixWidget: GetBuilder<DropDownController>(
                  id: 'country',
                  init: dropDownController,
                  builder: (controller) {
                    return SizedBox(
                      width: 100,
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            onSelect: (Country country) {
                              dropDownController.changeSelectedCountry(
                                  country:
                                      "${country.flagEmoji} ${country.phoneCode}");
                            },
                          );
                        },
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Text(dropDownController.selectedCountry),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              GetBuilder<ProfileController>(
                id : "updateProfile",
                init : profileController,
                builder : (controller)=> MyButton(
                  title: profileController.isUpdateLoading ? null : isNew ? 'Submit' : 'Update',
                  onPressed: () async {
                    if (isNew) {
                      if (profilePhoto == null) {
                        Get.showSnackbar(
                          MySnackbar(
                              success: false,
                              title: 'Missing Info',
                              message: "Please enter your profile picture"),
                        );
                        return;
                      }
                      if (_checkIsEmpty(firstNameController.text.trim())) {
                        Get.showSnackbar(
                          MySnackbar(
                              success: false,
                              title: 'Missing Info',
                              message: "Please enter your first name"),
                        );
                        return;
                      }

                      if (_checkIsEmpty(lastNameController.text.trim())) {
                        Get.showSnackbar(
                          MySnackbar(
                              success: false,
                              title: 'Missing Info',
                              message: "Please enter your last name"),
                        );
                        return;
                      }

                      if (_checkIsEmpty(countryController.text.trim())) {
                        Get.showSnackbar(
                          MySnackbar(
                              success: false,
                              title: 'Missing Info',
                              message: "Please enter your country"),
                        );
                        return;
                      }

                      if (_checkIsEmpty(birthDateController.text.trim())) {
                        Get.showSnackbar(
                          MySnackbar(
                              success: false,
                              title: 'Missing Info',
                              message: "Please enter your birth date"),
                        );
                        return;
                      }

                      if (_checkIsEmpty(dropDownController.selectedGender)) {
                        Get.showSnackbar(
                          MySnackbar(
                              success: false,
                              title: 'Missing Info',
                              message: "Please enter your gender"),
                        );
                        return;
                      }

                      if (_checkIsEmpty(phoneController.text.trim())) {
                        Get.showSnackbar(
                          MySnackbar(
                              success: false,
                              title: 'Missing Info',
                              message: "Please enter your phone number"),
                        );
                        return;
                      }
                    }
                    print("all entered.....");
                    profileController.changeIsUpdateLoading(true);
                    ProfileInfo? result = await AuthApis.updateProfile(
                      firstName: _handleNullValues(
                        firstNameController.text.trim(),
                        profileController.currentUserInfo?.firstName ?? 'Guest',
                      ),
                      lastName: _handleNullValues(
                        lastNameController.text.trim(),
                        profileController.currentUserInfo?.lastName ?? 'User',
                      ),
                      bdate: _handleNullValues(
                        birthDateController.text.trim(),
                        DateFormat('yyyy-MM-dd').format(
                            profileController.currentUserInfo?.birthDate ??
                                DateTime(2025)),
                      ),
                      country: _handleNullValues(
                        countryController.text.trim(),
                        profileController.currentUserInfo?.country ?? 'Syria',
                      ),
                      phoneNumber: _handleNullValues(
                        phoneController.text.trim(),
                        profileController.currentUserInfo?.phoneNumber ??
                            '000000000',
                      ),
                      photo: profilePhoto ?? profileController.profilePhoto,
                      gender: _handleNullValues(
                        dropDownController.selectedGender[0],
                        profileController.currentUserInfo?.gender ?? 'M',
                      ),
                    );
                    profileController.changeIsUpdateLoading(false);

                    print("got updating profile info result");
                    if (result != null) {
                      profileController.changeCurrentUserInfo(result);
                      if (isNew) {
                        Get.offAllNamed('/home');
                      } else {
                        Get.back();
                      }
                    } else {
                      Get.showSnackbar(
                        MySnackbar(
                          success: false,
                          title: 'Updating Profile',
                          message:
                              'Failed to update profile info , please try again later.',
                        ),
                      );
                    }
                  },
                ),
              ) 
            ],
          ),
        ),
      ),
    );
  }

  bool _checkIsEmpty(value) {
    return value == null || value == '';
  }

  GetBuilder<DropDownController> genderDropDownMenu() {
    return GetBuilder<DropDownController>(
      id: 'gender',
      init: dropDownController,
      builder: (controller) {
        return Container(
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
          child: DropdownButtonFormField(
            value: dropDownController.selectedGender,
            decoration: InputDecoration(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            items: dropDownController.genders.map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (gender) {
              dropDownController.changeSelectedGender(
                gender: gender,
              );
            },
            validator: (gender) =>
                gender == null ? "please choose a gender" : null,
          ),
        );
      },
    );
  }

  String _handleNullValues(String? value, String candValue) {
    if (value == null || value == '') {
      return candValue;
    } else {
      return value;
    }
  }

  MyInputField myProfileInput(
      {required String hint,
      Widget? suffixWidget,
      Widget? prefixWidget,
      required TextEditingController controller,
      bool? readOnly,
      void Function()? ontap,
      TextInputType? keyboardType}) {
    return MyInputField(
      keyboardType: keyboardType,
      prefixWidget: prefixWidget,
      ontap: ontap,
      readOnly: readOnly,
      controller: controller,
      suffixWidget: suffixWidget,
      hint: hint,
      borderSide: BorderSide.none,
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
}
