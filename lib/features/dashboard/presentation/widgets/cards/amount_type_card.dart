import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_formatter.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../../data/helper_models/amount_type_stats.dart';

class AmountTypeCard extends StatelessWidget {
  final AmountTypeStats amountTypeStats;
  final bool selected;
  final VoidCallback onTap;

  const AmountTypeCard({
    super.key,
    required this.amountTypeStats,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return Expanded(
      child: Card(
        elevation: 0,
        color: selected ? Colors.cyanAccent.withAlpha(40) : Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: selected ? Colors.cyanAccent : Colors.grey.withAlpha(40),
            width: 1.0,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.translate(amountTypeStats.name),
                  style: TextStyle(
                    color: selected ? Colors.cyanAccent : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  formatCurrency(amountTypeStats.amount, 'EUR'),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.cyanAccent : Colors.white,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${NumberFormat('#,##0.0', locale).format(amountTypeStats.percentage)} %',
                  style: TextStyle(
                    color: selected ? Colors.cyanAccent : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
