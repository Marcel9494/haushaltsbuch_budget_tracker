import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final VoidCallback? onTap;
  final Color color;

  const SettingsCard({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: ListTile(
          leading: leading,
          title: Text(
            title,
            style: TextStyle(color: color),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right_rounded,
            size: 24.0,
            color: color,
          ),
        ),
      ),
    );
  }
}
