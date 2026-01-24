import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../blocs/goal/goal_bloc.dart';
import '../../../../blocs/goal/goal_event.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/page_arguments/home_page_arguments.dart';
import '../../../../core/page_arguments/update_goal_page_arguments.dart';
import '../../../../core/utils/dialogs/show_delete_dialog.dart';
import '../../../../data/models/goal.dart';
import '../../../../data/repositories/goal_repository.dart';

class GoalBookingsPage extends StatefulWidget {
  final Goal goal;

  const GoalBookingsPage({
    super.key,
    required this.goal,
  });

  @override
  State<GoalBookingsPage> createState() => _GoalBookingsPageState();
}

class _GoalBookingsPageState extends State<GoalBookingsPage> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      create: (context) => GoalBloc(GoalRepository()),
      child: Builder(builder: (innerContext) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${widget.goal.goalName} ${t.translate('bookings')}'),
            actions: [
              IconButton(
                icon: Icon(Icons.edit_rounded),
                onPressed: () {
                  Navigator.pushNamed(context, updateGoalRoute, arguments: UpdateGoalPageArguments(widget.goal));
                },
              ),
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
          body: ListView.builder(
            itemCount: 5, // widget.bookings.length,
            itemBuilder: (context, index) {
              return Text('TODO');
              /*return BookingCard(
                booking: widget.bookings[index],
              );*/
            },
          ),
        );
      }),
    );
  }
}
