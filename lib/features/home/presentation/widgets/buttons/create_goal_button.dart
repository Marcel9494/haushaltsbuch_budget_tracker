import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/goal/goal_bloc.dart';
import '../../../../../blocs/goal/goal_state.dart';
import '../../../../../core/utils/premium_service.dart';
import '../../../../../core/utils/slow_hero_animation.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../goals/presentation/pages/create_goal_page.dart';

class CreateGoalButton extends StatelessWidget {
  const CreateGoalButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocSelector<GoalBloc, GoalState, int>(
      selector: (state) {
        if (state is GoalListLoaded) {
          return state.goals.length;
        }
        return 0;
      },
      builder: (context, goalCount) {
        return Hero(
          tag: 'create_goal_fab',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextButton.icon(
              onPressed: () async {
                final allowed = await PremiumService.checkLimit(limitReached: goalCount >= 1);
                if (allowed == false) {
                  return;
                }

                Navigator.push(
                  context,
                  slowHeroRoute(
                    BlocProvider.value(
                      value: context.read<GoalBloc>(),
                      child: CreateGoalPage(),
                    ),
                  ),
                );
              },
              label: Text(t.translate('create_goal')),
            ),
          ),
        );
      },
    );
  }
}
