import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/features/goals/presentation/widgets/buttons/complete_goal_button.dart';
import 'package:haushaltsbuch_budget_tracker/features/goals/presentation/widgets/charts/goal_line_chart.dart';
import 'package:haushaltsbuch_budget_tracker/features/goals/presentation/widgets/deco/goal_info_row.dart';
import 'package:haushaltsbuch_budget_tracker/features/goals/presentation/widgets/deco/goal_stat_row.dart';

import '../../../../../blocs/account/account_bloc.dart';
import '../../../../../blocs/booking/booking_bloc.dart';
import '../../../../../blocs/category/category_bloc.dart';
import '../../../../../blocs/goal/goal_bloc.dart';
import '../../../../../data/enums/goal_state_type.dart';
import '../../../../../data/models/goal.dart';
import '../../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/deco/error_text.dart';
import '../../pages/goal_bookings_page.dart';
import '../deco/completed_goal_stat_row.dart';

class GoalCard extends StatefulWidget {
  final Goal goal;

  const GoalCard({
    super.key,
    required this.goal,
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return CircularLoadingIndicator();
        } else if (state is BookingListLoaded) {
          return GestureDetector(
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
                  child: GoalBookingsPage(
                    goal: widget.goal,
                    goalBookings: state.bookings.where((b) => b.goalId == widget.goal.id).toList(),
                  ),
                ),
              ),
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GoalInfoRow(goal: widget.goal),
                    GoalLineChart(
                      goal: widget.goal,
                      goalBookings: state.bookings.where((b) => b.goalId == widget.goal.id).toList(),
                    ),
                    widget.goal.goalState == GoalStateType.active ? GoalStatRow(goal: widget.goal) : CompletedGoalStatRow(goal: widget.goal),
                    widget.goal.currentAmount! >= widget.goal.goalAmount && widget.goal.goalState == GoalStateType.active
                        ? CompleteGoalButton(goalId: widget.goal.id!)
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          );
        } else if (state is BookingError) {
          return ErrorText(errorMessage: state.message);
        }
        return SizedBox.shrink();
      },
    );
  }
}
