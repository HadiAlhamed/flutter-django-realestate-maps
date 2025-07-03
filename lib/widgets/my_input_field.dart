// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:real_estate/textstyles/text_colors.dart';

class MyInputField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool? isObsecure;
  final Widget? suffixWidget;
  final Widget? prefixWidget;

  final BoxDecoration? decoration;
  final BorderSide? borderSide;
  final bool? readOnly;
  final void Function()? ontap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const MyInputField({
    super.key,
    required this.hint,
    this.prefixIcon,
    this.isObsecure,
    this.suffixWidget,
    this.decoration,
    this.borderSide,
    this.controller,
    this.readOnly,
    this.ontap,
    this.prefixWidget,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        // onTapAlwaysCalled: true,
        validator: validator,
        onTap: ontap,
        readOnly: readOnly ?? false,
        controller: controller,
        obscureText: isObsecure ?? false,
        keyboardType: keyboardType,
        // style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
        decoration: InputDecoration(
          filled: true,
          suffixIcon: suffixWidget,
          hintText: hint,
          prefixIcon: prefixWidget ??
              (prefixIcon == null
                  ? null
                  : Icon(
                      prefixIcon,
                      color: primaryColor,
                    )),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: borderSide ??
                const BorderSide(color: primaryColorInactive, width: 3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide:
                borderSide ?? const BorderSide(color: primaryColor, width: 4),
          ),
        ),
      ),
    );
  }
}
