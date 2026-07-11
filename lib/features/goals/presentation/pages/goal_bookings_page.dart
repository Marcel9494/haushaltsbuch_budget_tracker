import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../blocs/account/account_bloc.dart';
import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../blocs/category/category_bloc.dart';
import '../../../../blocs/goal/goal_bloc.dart';
import '../../../../blocs/goal/goal_event.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/page_arguments/home_page_arguments.dart';
import '../../../../core/page_arguments/update_goal_page_arguments.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/dialogs/show_delete_dialog.dart';
import '../../../../data/enums/goal_state_type.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/models/goal.dart';
import '../../../bookings/presentation/widgets/cards/booking_card.dart';
import '../../../bookings/presentation/widgets/deco/booking_list_daily_header.dart';
import '../../../shared/presentation/widgets/deco/empty_list.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';
import '../widgets/charts/goal_line_chart.dart';
import '../widgets/deco/completed_goal_stat_row.dart';
import '../widgets/deco/goal_info_row.dart';
import '../widgets/deco/goal_stat_row.dart';

class GoalBookingsPage extends StatefulWidget {
  final Goal goal;
  List<Booking> goalBookings;

  GoalBookingsPage({
    super.key,
    required this.goal,
    required this.goalBookings,
  });

  @override
  State<GoalBookingsPage> createState() => _GoalBookingsPageState();
}

class _GoalBookingsPageState extends State<GoalBookingsPage> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<BookingBloc>()),
        BlocProvider.value(value: context.read<CategoryBloc>()),
        BlocProvider.value(value: context.read<AccountBloc>()),
        BlocProvider.value(value: context.read<GoalBloc>()),
      ],
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return CircularProgressIndicator();
          } else if (state is BookingListLoaded) {
            return Builder(builder: (innerContext) {
              widget.goalBookings = state.bookings.where((booking) => booking.goalId == widget.goal.id).toList();
              return Scaffold(
                appBar: AppBar(
                  title: Text('${widget.goal.goalName} ${t.translate('bookings')}'),
                  actions: [
                    widget.goal.goalState == GoalStateType.active
                        ? IconButton(
                            icon: Icon(Icons.edit_rounded),
                            onPressed: () {
                              Navigator.pushNamed(context, updateGoalRoute, arguments: UpdateGoalPageArguments(widget.goal));
                            },
                          )
                        : SizedBox.shrink(),
                    IconButton(
                      icon: Icon(Icons.delete_forever_rounded),
                      onPressed: () async {
                        final goalBloc = innerContext.read<GoalBloc>();
                        final navigator = Navigator.of(context);

                        final bool confirmed = await showDeleteDialog(
                          context,
                          t.translate('delete_goal'),
                          t.translate('delete_goal_confirmation'),
                        );

                        if (confirmed == true) {
                          goalBloc.add(DeleteGoal(goalId: widget.goal.id!));
                          navigator.pushNamedAndRemoveUntil(
                            homeRoute,
                            (route) => false,
                            arguments: HomePageArguments(4),
                          );
                        }
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GoalInfoRow(goal: widget.goal),
                            GoalLineChart(
                              goal: widget.goal,
                              goalBookings: widget.goalBookings.where((b) => b.goalId == widget.goal.id).toList(),
                            ),
                            widget.goal.goalState == GoalStateType.active ? GoalStatRow(goal: widget.goal) : CompletedGoalStatRow(goal: widget.goal),
                          ],
                        ),
                      ),
                    ),
                    widget.goalBookings.isEmpty
                        ? EmptyList(
                            text: 'no_goal_bookings',
                            icon: FaIcon(
                              FontAwesomeIcons.book,
                              size: 42.0,
                              color: Colors.white70,
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: widget.goalBookings.length,
                              itemBuilder: (context, index) {
                                final bool showHeader = index == 0
                                    ? true
                                    : !isSameDay(
                                        widget.goalBookings[index].bookingDate,
                                        widget.goalBookings[index - 1].bookingDate,
                                      );
                                return Column(
                                  children: [
                                    showHeader
                                        ? BookingListDailyHeader(
                                            bookings: widget.goalBookings, bookingDate: widget.goalBookings[index].bookingDate, index: index)
                                        : SizedBox.shrink(),
                                    BookingCard(
                                      booking: widget.goalBookings[index],
                                      onUpdateSuccess: () {
                                        Navigator.pop(context);
                                        context.read<BookingBloc>().add(LoadGoalBookings());
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                  ],
                ),
              );
            });
          } else if (state is BookingError) {
            return ErrorText(errorMessage: state.message);
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
