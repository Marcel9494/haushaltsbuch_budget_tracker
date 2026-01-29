import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/input_fields/title_input_field.dart';

import '../../../../../core/utils/app_flushbar.dart';
import '../../../../../l10n/app_localizations.dart';

void _guestLogoutConfirmation(BuildContext context, TextEditingController confirmTextController) {
  final t = AppLocalizations.of(context);
  if (confirmTextController.text.trim() == t.translate('guest_logout_confirmation_word')) {
    Navigator.of(context).pop(true);
  } else {
    AppFlushbar.show(
      context,
      message: t.translate('guest_logout_confirmation_failed'),
    );
  }
}

Future<bool> showGuestLogoutDialog(BuildContext context) async {
  final TextEditingController confirmTextController = TextEditingController();
  final t = AppLocalizations.of(context);
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.translate('logout')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.translate('guest_logout_description_important'),
              style: TextStyle(color: Colors.redAccent),
            ),
            SizedBox(height: 16.0),
            TitleInputField(
              titleController: confirmTextController,
              text: t.translate('guest_logout_confirmation_word'),
              showTitle: false,
            ),
            SizedBox(height: 16.0),
            Text(t.translate('guest_logout_description_notice')),
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
          onPressed: () => _guestLogoutConfirmation(context, confirmTextController),
          child: Text(t.translate('confirm')),
        ),
      ],
    ),
  );
  return confirmed!;
}
