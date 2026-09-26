import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/dialogs/show_complete_goal_dialog.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/goal_repository.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../../blocs/goal/goal_bloc.dart';
import '../../../../../blocs/goal/goal_event.dart';
import '../../../../../blocs/goal/goal_state.dart';
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
  // TODO confirmed Exception verhindern
  bool confirmed = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      create: (context) => GoalBloc(GoalRepository())..add(LoadCompletedGoals()),
      child: BlocBuilder<GoalBloc, GoalState>(
        builder: (context, state) {
          if (state is GoalLoading) {
            return const CircularProgressIndicator();
          } else if (state is GoalListLoaded) {
            return Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final bool allowed = await PremiumService.checkLimit(limitReached: state.goals.isNotEmpty);
                        if (allowed == false) {
                          return;
                        }
                        confirmed = await showCompleteGoalDialog(context);
                        if (confirmed) {
                          context.read<GoalBloc>().add(CompleteGoal(goalId: widget.goalId));
                        }
                      },
                      child: Text('${t.translate('complete_goal')}?'),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is GoalError) {
            return Text(t.translate(state.message));
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
