import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/budget/budget_bloc.dart';
import '../../../../../blocs/budget/budget_state.dart';
import '../../../../../blocs/category/category_bloc.dart';
import '../../../../../core/utils/premium_service.dart';
import '../../../../../core/utils/slow_hero_animation.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../budgets/presentation/pages/create_budget_page.dart';

class CreateBudgetButton extends StatelessWidget {
  const CreateBudgetButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocSelector<BudgetBloc, BudgetState, int>(
      selector: (state) {
        if (state is BudgetListLoaded) {
          return state.budgets.length;
        }
        return 0;
      },
      builder: (context, budgetCount) {
        return Hero(
          tag: 'create_budget_fab',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextButton.icon(
              onPressed: () async {
                final allowed = await PremiumService.checkLimit(limitReached: budgetCount >= 3);
                if (allowed == false) {
                  return;
                }

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
              label: Text(t.translate('create_budget')),
            ),
          ),
        );
      },
    );
  }
}
