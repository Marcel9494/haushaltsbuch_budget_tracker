import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../../data/enums/account_type.dart';

class AccountTypeInputField extends StatefulWidget {
  final TextEditingController accountTypeController;
  final AccountType accountType;
  final ValueChanged<AccountType> onAccountTypeChanged;

  const AccountTypeInputField({
    super.key,
    required this.accountTypeController,
    required this.accountType,
    required this.onAccountTypeChanged,
  });

  @override
  State<AccountTypeInputField> createState() => _AccountTypeInputFieldState();
}

class _AccountTypeInputFieldState extends State<AccountTypeInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(t.translate('account_type'), style: TextStyle(fontSize: 16.0)),
        ),
        TextFormField(
          controller: widget.accountTypeController,
          readOnly: true,
          focusNode: _focusNode,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.black87,
            prefixIcon: Icon(Icons.account_balance_rounded, size: 22.0),
            hintText: '${t.translate('account_type')}...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey, width: 0.3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey, width: 0.3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey, width: 0.3),
            ),
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              builder: (context) {
                final double bottomSheetHeight = MediaQuery.of(context).size.height * 0.65;
                return SafeArea(
                  child: SizedBox(
                    height: bottomSheetHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${t.translate('select_account_type')}:',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 28),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: AccountType.values.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        widget.accountTypeController.text = AccountType.values[index].name;
                                      });
                                      widget.onAccountTypeChanged(AccountType.values[index]);
                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: widget.accountType == AccountType.values[index] ? Colors.cyanAccent : Colors.grey,
                                          width: widget.accountType == AccountType.values[index] ? 1 : 0.5),
                                      backgroundColor: Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      t.translate(AccountType.values[index].name),
                                      style: TextStyle(color: widget.accountType == AccountType.values[index] ? Colors.cyanAccent : Colors.white70),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
