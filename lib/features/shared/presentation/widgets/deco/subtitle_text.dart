import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

class SubtitleText extends StatelessWidget {
  final String text;
  final double fontSize;

  const SubtitleText({
    super.key,
    required this.text,
    this.fontSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        t.translate(text),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
