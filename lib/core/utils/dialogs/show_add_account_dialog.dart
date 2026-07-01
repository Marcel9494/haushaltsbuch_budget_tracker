import 'package:flutter/material.dart';

import '../../../features/bookings/presentation/widgets/input_fields/title_input_field.dart';
import '../../../l10n/app_localizations.dart';

Future<bool> showAddAccountDialog(
  BuildContext context,
  TextEditingController accountNameController,
  Future<void> Function(String accountName) onCreate,
) async {
  final t = AppLocalizations.of(context);
  accountNameController.text = '';
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.translate('create_account')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.translate('create_account_text')),
          SizedBox(height: 12.0),
          TitleInputField(
            titleController: accountNameController,
            text: t.translate('account_name'),
            showTitle: false,
            autoFocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(t.translate('cancel')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black87,
            backgroundColor: Colors.cyanAccent,
          ),
          onPressed: () async {
            final name = accountNameController.text;
            await onCreate(name);
            Navigator.of(context).pop(true);
          },
          child: Text(t.translate('create')),
        ),
      ],
    ),
  );
  return confirmed!;
}
