import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/utils/app_flushbar.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../bookings/presentation/widgets/input_fields/title_input_field.dart';

void _deleteUserAccountConfirmation(BuildContext context, TextEditingController confirmTextController) {
  final t = AppLocalizations.of(context);
  if (confirmTextController.text.trim() == t.translate('delete_user_account_confirmation_word')) {
    Navigator.of(context).pop(true);
    _deleteUserAccount();
  } else {
    AppFlushbar.show(
      context,
      message: t.translate('delete_user_account_confirmation_failed'),
    );
  }
}

Future<void> _deleteUserAccount() async {
  try {
    await Supabase.instance.client.functions.invoke('delete-user-account');
    await Supabase.instance.client.auth.signOut();
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<bool> showDeleteUserAccountDialog(BuildContext context) async {
  final TextEditingController confirmTextController = TextEditingController();
  final t = AppLocalizations.of(context);
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.translate('delete_user_account')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.translate('delete_user_account_description_important'),
              style: TextStyle(color: Colors.redAccent),
            ),
            SizedBox(height: 16.0),
            TitleInputField(
              titleController: confirmTextController,
              text: t.translate('delete_user_account_confirmation_word'),
              showTitle: false,
            ),
          ],
        ),
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
            backgroundColor: Colors.redAccent,
          ),
          onPressed: () => _deleteUserAccountConfirmation(context, confirmTextController),
          child: Text(t.translate('delete')),
        ),
      ],
    ),
  );
  return confirmed!;
}
