import 'package:flutter/material.dart';

class GridItemButton extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final Color color;
  final double iconSize;
  final double textSize;
  final double borderRadius;
  final VoidCallback onTap;

  const GridItemButton({
    this.icon,
    this.text,
    this.color = Colors.white,
    this.iconSize = 28,
    this.textSize = 24,
    this.borderRadius = 12,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: color),
            ],
            if (text != null) ...[
              Text(
                text!,
                style: TextStyle(fontSize: textSize, color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
