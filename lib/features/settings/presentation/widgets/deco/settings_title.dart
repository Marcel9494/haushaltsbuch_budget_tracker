import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class SettingsTitle extends StatelessWidget {
  final String title;

  const SettingsTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0),
      child: Text(
        t.translate(title),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
