import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final double width;
  final double height;

  const AppIcon({
    super.key,
    this.width = 200,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/app_icon_transparent_background.png',
      width: width,
      height: height,
    );
  }
}
