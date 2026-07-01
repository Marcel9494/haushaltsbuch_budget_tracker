import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

class ChartTitle extends StatelessWidget {
  final double leftPadding;

  const ChartTitle({
    super.key,
    this.leftPadding = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 6.0, left: leftPadding),
      child: Text(
        t.translate('income_vs_expenses'),
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
