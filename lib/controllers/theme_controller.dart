import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/services/api.dart';

class ThemeController extends GetxController {
  // Observable to track theme mode
  Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  Future<void> init() async {
    bool? isDark =  Api.box.read('isDark');
    if (isDark == null || !isDark) {
      themeMode = ThemeMode.light.obs;
    }else{
      themeMode = ThemeMode.dark.obs;

    }
  }

  Future<void> toggleTheme() async {
    if (themeMode.value == ThemeMode.light) {
      themeMode.value = ThemeMode.dark;
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      themeMode.value = ThemeMode.light;
      Get.changeThemeMode(ThemeMode.light);
    }
    await Api.box.write('isDark', themeMode.value == ThemeMode.dark);
  }
}
