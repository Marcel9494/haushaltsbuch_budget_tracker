import 'package:flutter/material.dart';

class AddButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;

  const AddButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: widget.onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_rounded, size: 20.0, color: Colors.cyanAccent),
          const SizedBox(width: 4.0),
          Text(widget.text, style: TextStyle(color: Colors.cyanAccent)),
        ],
      ),
    );
  }
}
