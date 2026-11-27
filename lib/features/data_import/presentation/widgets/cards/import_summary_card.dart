import 'package:flutter/material.dart';

import '../../../../../data/helper_models/moneybook_import_plan.dart';
import '../../../../../l10n/app_localizations.dart';

// Zeigt an, wie viele Datensätze aus der Moneybook-Sicherung übernommen werden.
class ImportSummaryCard extends StatelessWidget {
  final MoneybookImportPlan plan;

  const ImportSummaryCard({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            _SummaryRow(label: t.translate('dataImportBookings'), value: plan.bookings.length),
            _SummaryRow(label: t.translate('dataImportNewAccounts'), value: plan.newAccounts.length),
            if (plan.reusedAccounts > 0) _SummaryRow(label: t.translate('dataImportReusedAccounts'), value: plan.reusedAccounts),
            _SummaryRow(label: t.translate('dataImportNewCategories'), value: plan.newCategories.length),
            if (plan.reusedCategories > 0) _SummaryRow(label: t.translate('dataImportReusedCategories'), value: plan.reusedCategories),
            _SummaryRow(label: t.translate('dataImportBudgets'), value: plan.budgets.length),
            _SummaryRow(label: t.translate('dataImportNewGoals'), value: plan.newGoals.length),
            if (plan.reusedGoals > 0) _SummaryRow(label: t.translate('dataImportReusedGoals'), value: plan.reusedGoals),
            if (plan.skippedBookings > 0)
              _SummaryRow(label: t.translate('dataImportSkippedBookings'), value: plan.skippedBookings, color: Colors.orangeAccent),
            if (plan.skippedBudgets > 0)
              _SummaryRow(label: t.translate('dataImportSkippedBudgets'), value: plan.skippedBudgets, color: Colors.orangeAccent),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: color)),
          ),
          const SizedBox(width: 12.0),
          Text(
            value.toString(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
