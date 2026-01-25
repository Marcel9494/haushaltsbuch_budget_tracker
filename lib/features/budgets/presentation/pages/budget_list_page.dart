import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/budget/budget_bloc.dart';
import '../../../../blocs/budget/budget_event.dart';
import '../../../../data/enums/period_of_time_type.dart';
import '../../../../data/repositories/budget_repository.dart';
import '../widgets/list_views/monthly_budget_list.dart';
import '../widgets/list_views/yearly_budget_list.dart';

class BudgetListPage extends StatefulWidget {
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;
  final ValueChanged<PeriodOfTimeType>? onPeriodOfTimeChanged;

  const BudgetListPage({
    super.key,
    required this.currentSelectedDate,
    required this.currentPeriodOfTimeType,
    required this.onPeriodOfTimeChanged,
  });

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  BudgetBloc _budgetBloc = BudgetBloc(BudgetRepository());
  BudgetRepository budgetRepository = BudgetRepository();

  @override
  void initState() {
    super.initState();
    _budgetBloc = context.read<BudgetBloc>();
    _loadBudgets();
  }

  void _loadBudgets() {
    _budgetBloc.add(
      LoadMonthlyBudgets(widget.currentSelectedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          widget.currentPeriodOfTimeType == PeriodOfTimeType.monthly
              ? Expanded(
                  child: MonthlyBudgetList(
                    currentSelectedDate: widget.currentSelectedDate,
                    currentPeriodOfTimeType: widget.currentPeriodOfTimeType,
                    onPeriodOfTimeChanged: widget.onPeriodOfTimeChanged,
                  ),
                )
              : Expanded(
                  child: YearlyBudgetList(
                    currentSelectedDate: widget.currentSelectedDate,
                    currentPeriodOfTimeType: widget.currentPeriodOfTimeType,
                    onPeriodOfTimeChanged: widget.onPeriodOfTimeChanged,
                  ),
                )
        ],
      ),
    );
  }
}
