import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/blocs/account/account_event.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/account_repository.dart';

import '../../../blocs/account/account_bloc.dart';
import '../../../data/models/account.dart';
import '../../../features/bookings/presentation/widgets/input_fields/account_input_field.dart';
import '../../../l10n/app_localizations.dart';

Future<bool> showTransferAccountDialog(
  BuildContext context,
  TextEditingController accountController,
  final ValueChanged<Account> onAccountChanged,
) async {
  final t = AppLocalizations.of(context);
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => BlocProvider(
      create: (context) => AccountBloc(AccountRepository())..add(LoadAccounts()),
      child: AlertDialog(
        title: Text(t.translate('transfer_account')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.translate('transfer_account_text')),
            SizedBox(height: 12.0),
            AccountInputField(
              accountController: accountController,
              text: 'account',
              showSuffixIcon: true,
              onAccountChanged: onAccountChanged,
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
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.translate('transmitted')),
          ),
        ],
      ),
    ),
  );
  return confirmed!;
}
