// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/textstyles/text_styles.dart';

class MyButton extends StatelessWidget {
  final String? title;
  final void Function()? onPressed;
  final double? width;
  final bool? fitParent;
  final ButtonStyle? buttonStyle;
  final TextStyle? textStyle;
  const MyButton({
    super.key,
    required this.title,
    this.onPressed,
    this.width,
    this.fitParent,
    this.buttonStyle,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fitParent == null || fitParent == false
          ? width ?? double.infinity
          : null,
      margin: fitParent == null || fitParent == false
          ? const EdgeInsets.only(bottom: 23)
          : null,
      child: TextButton(
        style: buttonStyle ??
            ButtonStyle(
              overlayColor: const WidgetStatePropertyAll(
                  Color.fromARGB(255, 214, 167, 224)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.all(12),
              ),
              backgroundColor: WidgetStateProperty.all(primaryColor),
            ),
        onPressed: onPressed ?? () {},
        child: title == null
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                title!,
                style: textStyle ?? buttonTextStyleWhite,
              ),
      ),
    );
  }
}
