import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class AnimatedLoadingButton extends StatelessWidget {
  final String text;
  final RoundedLoadingButtonController controller;
  final VoidCallback? onPressed;
  final double horizontalPadding;
  final Color buttonColor;
  final Color textColor;

  const AnimatedLoadingButton({
    super.key,
    required this.text,
    required this.controller,
    required this.onPressed,
    this.horizontalPadding = 24.0,
    this.buttonColor = const Color(0xFF424242),
    this.textColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: RoundedLoadingButton(
        controller: controller,
        onPressed: onPressed,
        color: buttonColor,
        borderRadius: 12.0,
        height: 38.0,
        successColor: Colors.green,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
