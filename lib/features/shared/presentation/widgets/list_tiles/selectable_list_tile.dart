import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SelectableListTile extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final String text;
  final VoidCallback onTap;

  const SelectableListTile({
    super.key,
    required this.icon,
    required this.selected,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.cyanAccent : Colors.white;

    return ListTile(
      leading: FaIcon(icon, size: 24, color: color),
      title: Text(text, style: TextStyle(fontSize: 18, color: color)),
      trailing: Icon(Icons.keyboard_arrow_right_rounded, size: 24, color: color),
      onTap: onTap,
    );
  }
}
