import 'package:flutter/material.dart';

import '../../../../../data/enums/chart_filter_type.dart';
import '../../../../../l10n/app_localizations.dart';

class ChartTitle extends StatelessWidget {
  final double leftPadding;
  final ChartFilterType selectedChartFilter;

  const ChartTitle({
    super.key,
    this.leftPadding = 20.0,
    required this.selectedChartFilter,
  });

  String _getTitle(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isExpenses = selectedChartFilter.name == ChartFilterType.expenses.name;
    final isRevenue = selectedChartFilter.name == ChartFilterType.revenue.name;
    final isComparison = selectedChartFilter.name == ChartFilterType.comparison.name;

    if (isComparison) {
      return t.translate('income_vs_expenses');
    }
    if (isRevenue) {
      return t.translate('revenue');
    }
    if (isExpenses) {
      return t.translate('expenses');
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: leftPadding,
      ),
      child: Text(
        _getTitle(context),
        style: TextStyle(
          fontSize: selectedChartFilter.name == ChartFilterType.comparison.name ? 14.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
