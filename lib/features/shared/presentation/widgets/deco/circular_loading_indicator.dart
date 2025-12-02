import 'package:flutter/material.dart';

class CircularLoadingIndicator extends StatelessWidget {
  const CircularLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.cyanAccent,
      ),
    );
  }
}
