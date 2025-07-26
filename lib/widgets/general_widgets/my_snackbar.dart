import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MySnackbar extends GetSnackBar {
  MySnackbar({
    super.key,
    required bool success,
    required String title,
    required String message,
  }) : super(
          backgroundColor: success ? Colors.green : Colors.red,
          title: title,
          message: message,
          duration: const Duration(seconds: 3),
          icon: Icon(success ? Icons.check : Icons.error),
          isDismissible: true,
          snackPosition: SnackPosition.TOP,
        );
}
