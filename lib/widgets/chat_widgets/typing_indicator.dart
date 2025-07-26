import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final Color dotColor;
  const TypingIndicator({super.key, required this.dotColor});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dotAnimations = List.generate(3, (i) {
      return Tween<double>(begin: 0.5, end: 1.5).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.2, i * 0.2 + 0.6, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return ScaleTransition(
      scale: _dotAnimations[index],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          '.',
          style: TextStyle(
            fontSize: 16,
            color: widget.dotColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, _buildDot),
    );
  }
}
