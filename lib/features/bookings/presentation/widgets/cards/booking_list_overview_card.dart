import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_formatter.dart';

import '../../../../../l10n/app_localizations.dart';

class BookingListOverviewCard extends StatelessWidget {
  final String title;
  final double amount;
  final int daysInMonth;
  final Color color;

  const BookingListOverviewCard({
    super.key,
    required this.title,
    required this.amount,
    required this.daysInMonth,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
                child: Text(
                  t.translate(title),
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0, bottom: 2.0),
                child: Text(
                  formatCurrency(amount, 'EUR'),
                  style: TextStyle(fontSize: 16.0, color: color),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0, bottom: 6.0),
                child: Text(
                  '\u00D8 ${formatCurrency(amount / daysInMonth, 'EUR')} ${t.translate('per_day')}',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
