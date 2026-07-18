import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_helper.dart';

import '../../../../../core/consts/route_consts.dart';
import '../../../../../core/page_arguments/update_account_page_arguments.dart';
import '../../../../../data/models/account.dart';

class AccountCard extends StatelessWidget {
  final Account account;

  const AccountCard({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, updateAccountRoute, arguments: UpdateAccountPageArguments(account)),
      child: Card(
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: account.balance >= 0 ? Colors.green : Colors.redAccent, width: 4.0)),
            ),
            child: ListTile(
              title: Text(
                account.name,
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                CurrencyHelper.instance.formatCurrency(account.balance, context),
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
