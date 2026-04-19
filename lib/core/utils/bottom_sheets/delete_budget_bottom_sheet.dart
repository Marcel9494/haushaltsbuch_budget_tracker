import 'package:flutter/material.dart';

import '../../../blocs/budget/budget_bloc.dart';
import '../../../blocs/budget/budget_event.dart';
import '../../../data/enums/budget_selection_type.dart';
import '../../../data/models/budget.dart';
import '../../../l10n/app_localizations.dart';
import '../../consts/route_consts.dart';
import '../../page_arguments/home_page_arguments.dart';
import '../date_formatter.dart';
import '../dialogs/show_delete_dialog.dart';

void showDeleteBudgetBottomSheet(BuildContext context, Budget budget, BudgetBloc budgetBloc) {
  final t = AppLocalizations.of(context);
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14.0),
                      child: Text(
                        t.translate('delete_budget'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: BudgetSelectionType.values.length,
                itemBuilder: (context, index) {
                  final selectionType = BudgetSelectionType.values[index];
                  return ListTile(
                    title: Text(
                      t.translate(selectionType.name),
                      style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${t.translate(selectionType.deleteDescription(budget.category!.categoryName))} '
                      '${selectionType == BudgetSelectionType.single ? '(${formatMonthYear(context, budget.budgetDate!)})' : ''}',
                      style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded, size: 24.0),
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      final budgetSelectionType = BudgetSelectionType.values[index];
                      Navigator.pop(context);

                      final bool confirmed = await showDeleteDialog(
                        context,
                        t.translate('delete_budget'),
                        budgetSelectionType.deleteDescription(budget.category!.categoryName),
                      );

                      if (confirmed == true) {
                        budgetBloc.add(
                          DeleteBudget(
                            budget: budget,
                            budgetSelectionType: budgetSelectionType,
                          ),
                        );
                        navigator.pushNamedAndRemoveUntil(
                          homeRoute,
                          (route) => false,
                          arguments: HomePageArguments(3),
                        );
                      }
                    },
                  );
                },
                separatorBuilder: (context, index) => const Divider(height: 1),
              ),
            ],
          ),
        ),
      );
    },
  );
}
