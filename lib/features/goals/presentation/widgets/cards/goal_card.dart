import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/features/goals/presentation/widgets/charts/goal_line_chart.dart';
import 'package:haushaltsbuch_budget_tracker/features/goals/presentation/widgets/deco/goal_info_row.dart';
import 'package:haushaltsbuch_budget_tracker/features/goals/presentation/widgets/deco/goal_stat_row.dart';

import '../../../../../blocs/booking/booking_bloc.dart';
import '../../../../../core/consts/route_consts.dart';
import '../../../../../core/page_arguments/goal_bookings_page_arguments.dart';
import '../../../../../data/models/goal.dart';
import '../../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/deco/error_text.dart';

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
        } else if (state is GoalBookingListLoaded) {
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              goalBookingsRoute,
              arguments: GoalBookingsPageArguments(
                widget.goal,
                state.goalBookings.where((b) => b.goalId == widget.goal.id).toList(),
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
                      goalBookings: state.goalBookings.where((b) => b.goalId == widget.goal.id).toList(),
                    ),
                    GoalStatRow(goal: widget.goal),
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
