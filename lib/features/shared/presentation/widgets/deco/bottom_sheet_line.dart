import 'package:flutter/material.dart';

class BottomSheetLine extends StatelessWidget {
  const BottomSheetLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Center(
        child: Container(
          width: 42.0,
          height: 5.0,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(100.0),
          ),
        ),
      ),
    );
  }
}
