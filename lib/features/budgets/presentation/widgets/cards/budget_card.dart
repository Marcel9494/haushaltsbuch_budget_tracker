import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../blocs/account/account_bloc.dart';
import '../../../../../blocs/booking/booking_bloc.dart';
import '../../../../../blocs/category/category_bloc.dart';
import '../../../../../blocs/goal/goal_bloc.dart';
import '../../../../../core/utils/currency_helper.dart';
import '../../../../../data/enums/period_of_time_type.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../data/models/budget.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../pages/budget_bookings_page.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final List<Booking> bookings;
  final double usedBudgetAmount;
  final double percentageUsed;
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTime;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.bookings,
    required this.usedBudgetAmount,
    required this.percentageUsed,
    required this.currentSelectedDate,
    required this.currentPeriodOfTime,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final Color color = budget.budgetAmount - usedBudgetAmount >= 0 ? Colors.green : Colors.redAccent;
    return SlideAnimation(
      verticalOffset: 40.0,
      child: FadeInAnimation(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<BookingBloc>()),
                  BlocProvider.value(value: context.read<CategoryBloc>()),
                  BlocProvider.value(value: context.read<AccountBloc>()),
                  BlocProvider.value(value: context.read<GoalBloc>()),
                ],
                child: BudgetBookingsPage(
                  budget: budget,
                  bookings: bookings,
                  currentSelectedDate: currentSelectedDate,
                  currentPeriodOfTimeType: currentPeriodOfTime,
                ),
              ),
            ),
          ),
          child: Card(
            child: ClipPath(
              clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: color,
                      width: 3.5,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 6.0),
                      CircularPercentIndicator(
                        radius: 40.0,
                        lineWidth: 6.0,
                        animation: true,
                        percent: (percentageUsed).clamp(0.0, 1.0),
                        center: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '${NumberFormat('#,##0.0', locale).format(percentageUsed * 100)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: color,
                      ),
                      const SizedBox(width: 12.0),
                      Container(
                        height: 96.0,
                        width: 1.3,
                        color: Colors.white30,
                        margin: const EdgeInsets.symmetric(horizontal: 6.0),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                '${budget.category!.categoryName}:',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${t.translate('budget')}:'),
                                        Text('${t.translate('consumed')}:'),
                                        SizedBox(height: 8.0),
                                        Text('${t.translate('remaining')}:'),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(6.0, 0.0, 12.0, 6.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          CurrencyHelper.instance.formatCurrency(budget.budgetAmount, context),
                                          style: const TextStyle(color: Colors.green),
                                        ),
                                        Text(
                                          CurrencyHelper.instance.formatCurrency(usedBudgetAmount, context),
                                          style: const TextStyle(color: Colors.redAccent),
                                        ),
                                        const Divider(height: 8.0, endIndent: 12.0),
                                        Text(
                                          CurrencyHelper.instance.formatCurrency(budget.budgetAmount - usedBudgetAmount, context),
                                          style: TextStyle(color: color),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
