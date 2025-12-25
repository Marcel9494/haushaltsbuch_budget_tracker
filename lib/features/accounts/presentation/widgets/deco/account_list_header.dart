import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/account_type.dart';

import '../../../../../data/models/account.dart';

class AccountListHeader extends StatefulWidget {
  final List<Account> accounts;
  final int index;

  const AccountListHeader({
    super.key,
    required this.accounts,
    required this.index,
  });

  @override
  State<AccountListHeader> createState() => _AccountListHeaderState();
}

class _AccountListHeaderState extends State<AccountListHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.accounts[widget.index].accountType.pluralName,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
