import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final VoidCallback? onTap;

  const SettingsCard({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: ListTile(
          leading: leading,
          title: Text(title),
          trailing: const Icon(
            Icons.keyboard_arrow_right_rounded,
            size: 24.0,
          ),
        ),
      ),
    );
  }
}
