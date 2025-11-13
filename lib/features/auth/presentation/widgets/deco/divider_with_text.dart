import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1.0,
            indent: 30,
            endIndent: 20,
          ),
        ),
        Text(text, style: TextStyle(fontSize: 16.0)),
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1.0,
            indent: 20,
            endIndent: 30,
          ),
        ),
      ],
    );
  }
}
