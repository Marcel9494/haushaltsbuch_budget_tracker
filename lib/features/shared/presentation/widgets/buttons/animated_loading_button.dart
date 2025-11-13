import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class AnimatedLoadingButton extends StatelessWidget {
  final String text;
  final RoundedLoadingButtonController controller;
  final VoidCallback? onPressed;

  const AnimatedLoadingButton({
    super.key,
    required this.text,
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: RoundedLoadingButton(
        controller: controller,
        onPressed: onPressed,
        color: Color(0xFF424242),
        borderRadius: 12.0,
        height: 38.0,
        successColor: Colors.green,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
