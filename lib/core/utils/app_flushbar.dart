import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class AppFlushbar {
  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.error,
    Color iconColor = Colors.redAccent,
    Duration duration = const Duration(seconds: 4),
  }) {
    Flushbar(
      message: message,
      duration: duration,
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.circular(8.0),
      margin: const EdgeInsets.all(8.0),
      icon: Icon(icon, color: iconColor),
    ).show(context);
  }
}
