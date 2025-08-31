// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:real_estate/textstyles/text_colors.dart';

class MyRowButton extends StatelessWidget {
  final Widget child;
  final void Function()? onPressed;
  const MyRowButton({
    super.key,
    required this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 23),
      child: TextButton(
        style: ButtonStyle(
          overlayColor:
              const WidgetStatePropertyAll(Color.fromARGB(255, 214, 167, 224)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.only(top: 12, bottom: 12),
          ),
          backgroundColor: WidgetStateProperty.all(primaryColor),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
