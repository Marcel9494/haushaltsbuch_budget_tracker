import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

Future<bool> showUserLogoutDialog(BuildContext context) async {
  final t = AppLocalizations.of(context);
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.translate('logout')),
      content: Text(t.translate('user_logout_description')),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(t.translate('cancel')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black87,
            backgroundColor: Colors.redAccent,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(t.translate('confirm')),
        ),
      ],
    ),
  );
  return confirmed!;
}
