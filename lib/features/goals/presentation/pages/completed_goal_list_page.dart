import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../blocs/goal/goal_bloc.dart';
import '../../../../blocs/goal/goal_event.dart';
import '../../../../blocs/goal/goal_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../data/models/goal.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/repositories/goal_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/empty_list.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';
import '../widgets/cards/goal_card.dart';

class CompletedGoalListPage extends StatefulWidget {
  const CompletedGoalListPage({super.key});

  @override
  State<CompletedGoalListPage> createState() => _CompletedGoalListPageState();
}

class _CompletedGoalListPageState extends State<CompletedGoalListPage> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.translate('completed_goals'),
        ),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => GoalBloc(GoalRepository())..add(LoadCompletedGoals())),
          BlocProvider(create: (context) => BookingBloc(BookingRepository(), AccountRepository())..add(LoadGoalBookings())),
        ],
        child: BlocBuilder<BookingBloc, BookingState>(
          builder: (context, bookingState) {
            return BlocBuilder<GoalBloc, GoalState>(builder: (context, state) {
              if (state is GoalLoading || bookingState is BookingLoading) {
                return CircularLoadingIndicator();
              } else if (state is GoalListLoaded && bookingState is GoalBookingListLoaded) {
                return Column(
                  children: [
                    SizedBox(height: 8.0),
                    state.goals.isEmpty
                        ? EmptyList(
                            text: 'no_goals',
                            icon: FaIcon(
                              FontAwesomeIcons.book,
                              size: 42.0,
                              color: Colors.white70,
                            ),
                          )
                        : Expanded(
                            child: AnimationLimiter(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: state.goals.length,
                                itemBuilder: (context, index) {
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: listAnimationDurationInMs),
                                    child: SlideAnimation(
                                      verticalOffset: 40.0,
                                      child: FadeInAnimation(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            BlocSelector<GoalBloc, GoalState, List<Goal>>(
                                              selector: (state) {
                                                if (state is GoalListLoaded) {
                                                  return state.goals;
                                                }
                                                return const [];
                                              },
                                              builder: (context, bookings) {
                                                return GoalCard(goal: state.goals[index]);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                  ],
                );
              } else if (state is GoalError) {
                return ErrorText(errorMessage: state.message);
              }
              return SizedBox.shrink();
            });
          },
        ),
      ),
    );
  }
}
