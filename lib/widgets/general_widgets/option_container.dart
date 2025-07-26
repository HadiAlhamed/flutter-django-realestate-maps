import 'package:flutter/material.dart';
import 'package:real_estate/textstyles/text_colors.dart';

class OptionContainer extends StatelessWidget {
  final void Function()? onTap;
  final String label;
  final bool colorCondition;
  const OptionContainer(
      {super.key,
      required this.onTap,
      required this.label,
      required this.colorCondition});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: FittedBox(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: colorCondition ? primaryColor : Colors.grey,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.3),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                )
              ],
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
