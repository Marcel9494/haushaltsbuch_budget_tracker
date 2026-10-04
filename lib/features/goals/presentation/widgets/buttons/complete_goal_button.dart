import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/core/consts/route_consts.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/dialogs/show_complete_goal_dialog.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/goal_repository.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../../blocs/goal/goal_bloc.dart';
import '../../../../../blocs/goal/goal_event.dart';
import '../../../../../blocs/goal/goal_state.dart';
import '../../../../../core/page_arguments/home_page_arguments.dart';
import '../../../../../core/utils/premium_service.dart';

class CompleteGoalButton extends StatefulWidget {
  final String goalId;

  const CompleteGoalButton({
    super.key,
    required this.goalId,
  });

  @override
  State<CompleteGoalButton> createState() => _CompleteGoalButtonState();
}

class _CompleteGoalButtonState extends State<CompleteGoalButton> {
  late final GoalBloc _goalBloc;

  @override
  void initState() {
    super.initState();
    _goalBloc = GoalBloc(GoalRepository());
    _goalBloc.add(LoadCompletedGoals());
  }

  @override
  void dispose() {
    _goalBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => GoalBloc(GoalRepository())..add(LoadCompletedGoals()),
      child: BlocListener<GoalBloc, GoalState>(
        listener: (context, state) {
          if (state is GoalCompleted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              homeRoute,
              (route) => false,
              arguments: HomePageArguments(4),
            );
          }
        },
        child: BlocBuilder<GoalBloc, GoalState>(
          builder: (context, state) {
            if (state is GoalLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GoalListLoaded) {
              return Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final bool allowed = await PremiumService.checkLimit(
                            limitReached: state.goals.isNotEmpty,
                            locale: Localizations.localeOf(context),
                          );
                          if (!allowed) {
                            return;
                          }
                          final bool confirmed = await showCompleteGoalDialog(context);
                          if (confirmed) {
                            context.read<GoalBloc>().add(
                                  CompleteGoal(
                                    goalId: widget.goalId,
                                  ),
                                );
                          }
                        },
                        child: Text('${t.translate('complete_goal')}?'),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
