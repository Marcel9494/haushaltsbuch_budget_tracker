import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/goal_repository.dart';
import 'package:haushaltsbuch_budget_tracker/features/goals/presentation/widgets/buttons/goal_diagram_type_segmented_button.dart';

import '../../../../blocs/goal/goal_bloc.dart';
import '../../../../blocs/goal/goal_event.dart';
import '../../../../blocs/goal/goal_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/slow_hero_animation.dart';
import '../../../../data/enums/goal_diagram_type.dart';
import '../../../../data/models/goal.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/empty_list.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';
import '../widgets/cards/goal_card.dart';
import 'create_goal_page.dart';

class GoalListPage extends StatefulWidget {
  const GoalListPage({super.key});

  @override
  State<GoalListPage> createState() => _GoalListPageState();
}

class _GoalListPageState extends State<GoalListPage> {
  GoalBloc _goalBloc = GoalBloc(GoalRepository());
  GoalDiagramType _goalDiagramType = GoalDiagramType.line;

  @override
  void initState() {
    super.initState();
    _goalBloc = context.read<GoalBloc>();
    _loadGoals();
  }

  void _loadGoals() {
    _goalBloc.add(
      LoadGoals(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<GoalBloc, GoalState>(
      builder: (context, state) {
        if (state is GoalLoading) {
          return CircularLoadingIndicator();
        } else if (state is GoalListLoaded) {
          return Column(
            children: [
              SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: 'create_goal_fab',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: OutlinedButton.icon(
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
                        icon: Icon(Icons.add_rounded),
                        label: Text(t.translate('create_goal')),
                      ),
                    ),
                  ),
                  GoalDiagramTypeSegmentedButton(
                    goalDiagramType: _goalDiagramType,
                    onChanged: (newGoalDiagramType) {
                      setState(() {
                        _goalDiagramType = newGoalDiagramType;
                      });
                    },
                  ),
                ],
              ),
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
                                          // final double usedBudgetAmount = _goalRepository.calculateUsedAmountForBudget(state.goals[index], bookings);
                                          // final double percentageUsed = (usedBudgetAmount / state.goals[index].amount);
                                          return GoalCard(
                                            goal: state.goals[index],
                                            goalDiagramType: _goalDiagramType,
                                          );
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
      },
    );
  }
}
