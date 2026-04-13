import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

Future<bool> showDeleteDialog(BuildContext context, String title, String content) async {
  final t = AppLocalizations.of(context);
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.translate(title)),
      content: Text(content),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(t.translate('no')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black87,
            backgroundColor: Colors.redAccent,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(t.translate('yes')),
        ),
      ],
    ),
  );
  return confirmed!;
}
