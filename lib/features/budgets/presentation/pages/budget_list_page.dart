import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/blocs/category/category_bloc.dart';

import '../../../../blocs/budget/budget_bloc.dart';
import '../../../../blocs/budget/budget_event.dart';
import '../../../../blocs/budget/budget_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/slow_hero_animation.dart';
import '../../../../data/repositories/budget_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/empty_list.dart';
import '../widgets/cards/budget_card.dart';
import 'create_budget_page.dart';

class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key});

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  BudgetBloc _budgetBloc = BudgetBloc(BudgetRepository());

  @override
  void initState() {
    super.initState();
    _budgetBloc = context.read<BudgetBloc>();
    _loadBudgets();
  }

  void _loadBudgets() {
    _budgetBloc.add(
      LoadBudgets(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return CircularLoadingIndicator();
          } else if (state is BudgetListLoaded) {
            if (state.budgets.isEmpty) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Hero(
                    tag: 'create_budget_fab',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            slowHeroRoute(
                              BlocProvider.value(
                                value: context.read<CategoryBloc>(),
                                child: CreateBudgetPage(),
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.add_rounded),
                        label: Text(t.translate('create_budget')),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Hero(
                        tag: 'create_budget_fab',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                slowHeroRoute(
                                  BlocProvider.value(
                                    value: context.read<CategoryBloc>(),
                                    child: CreateBudgetPage(),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.add_rounded),
                            label: Text(t.translate('create_budget')),
                          ),
                        ),
                      ),
                    ],
                  ),
                  state.budgets.isEmpty
                      ? EmptyList(
                          text: 'no_budgets',
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
                              itemCount: state.budgets.length,
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
                                          BudgetCard(budget: state.budgets[index]),
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
            }
          } else if (state is BudgetError) {
            return Center(child: Text(state.message));
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
