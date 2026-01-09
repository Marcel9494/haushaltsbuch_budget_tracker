import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/goal/goal_bloc.dart';
import '../../../../core/utils/slow_hero_animation.dart';
import '../../../../l10n/app_localizations.dart';
import 'create_goal_page.dart';

class GoalListPage extends StatefulWidget {
  const GoalListPage({super.key});

  @override
  State<GoalListPage> createState() => _GoalListPageState();
}

class _GoalListPageState extends State<GoalListPage> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: Hero(
        tag: 'create_goal_fab',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: OutlinedButton(
            onPressed: () {
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
            child: Text(t.translate('create_goal')),
          ),
        ),
      ),
    );
  }
}
