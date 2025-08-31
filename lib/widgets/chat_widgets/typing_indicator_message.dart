import 'package:flutter/material.dart';
import 'package:flutter_typing_indicator/flutter_typing_indicator.dart';
import 'package:real_estate/textstyles/text_colors.dart';

class TypingIndicatorMessage extends StatelessWidget {
  const TypingIndicatorMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      alignment: Alignment.centerLeft,
      child: TypingIndicator(
        dotColor: primaryColor,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.blueGrey.withAlpha((0.1 * 255).round())
            : Colors.blueGrey[300]!.withAlpha((0.4 * 255).round()),
        dotSize: 10.0,
        dotCount: 3,
        duration: Duration(milliseconds: 1500),
        padding: 12.0,
        dotShape: BoxShape.circle,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.zero,
          bottomRight: const Radius.circular(12),
        ),
        // borderRadius: BorderRadius.all(Radius.circular(15.0)),
        dotShadow: [BoxShadow(blurRadius: 2, color: Colors.black)],
        isGradient: true,
        dotGradient: LinearGradient(
          colors: [primaryColor, primaryColorInactive],
        ),
      ),
    );
  }
}
