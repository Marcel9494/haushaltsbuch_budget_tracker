import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_helper.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/account_type.dart';

import '../../../../../data/models/account.dart';
import '../../../../../l10n/app_localizations.dart';

class AccountListHeader extends StatefulWidget {
  final List<Account> accounts;
  final double accountTypeBalance;
  final int index;

  const AccountListHeader({
    super.key,
    required this.accounts,
    required this.accountTypeBalance,
    required this.index,
  });

  @override
  State<AccountListHeader> createState() => _AccountListHeaderState();
}

class _AccountListHeaderState extends State<AccountListHeader> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 31.0, 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t.translate(widget.accounts[widget.index].accountType.pluralName),
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            CurrencyHelper.instance.formatCurrency(widget.accountTypeBalance, context),
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: widget.accountTypeBalance >= 0.0 ? Colors.green : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
