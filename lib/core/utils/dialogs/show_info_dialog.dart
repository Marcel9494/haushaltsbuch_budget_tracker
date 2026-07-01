import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

Future<void> showInfoDialog(BuildContext context, String title, String content) async {
  final t = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.translate(title)),
      content: Text(t.translate(content)),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black87,
            backgroundColor: Colors.cyanAccent,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.translate('ok')),
        ),
      ],
    ),
  );
}
