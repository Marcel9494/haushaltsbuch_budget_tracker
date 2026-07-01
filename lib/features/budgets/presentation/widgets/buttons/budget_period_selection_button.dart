import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_formatter.dart';

import '../../../../../l10n/app_localizations.dart';

class BudgetPeriodSelectionButton extends StatefulWidget {
  final double currentBudgetAmount;

  const BudgetPeriodSelectionButton({
    super.key,
    required this.currentBudgetAmount,
  });

  @override
  State<BudgetPeriodSelectionButton> createState() => _BudgetPeriodSelectionButtonState();
}

class _BudgetPeriodSelectionButtonState extends State<BudgetPeriodSelectionButton> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(FontAwesomeIcons.calendarDays, size: 24.0),
                const SizedBox(height: 8),
                Text(
                  '${t.translate('monthly_budget')}\n${formatCurrency(widget.currentBudgetAmount, 'EUR')}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const FaIcon(FontAwesomeIcons.equals, size: 20.0),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(FontAwesomeIcons.calendar, size: 24.0),
                const SizedBox(height: 8),
                Text(
                  '${t.translate('yearly_budget')}\n${formatCurrency(widget.currentBudgetAmount * 12, 'EUR')}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
