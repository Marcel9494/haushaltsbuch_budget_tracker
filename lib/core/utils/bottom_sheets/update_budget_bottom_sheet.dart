import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/features/budgets/presentation/pages/update_budget_page.dart';

import '../../../blocs/category/category_bloc.dart';
import '../../../data/enums/budget_selection_type.dart';
import '../../../data/models/budget.dart';
import '../../../l10n/app_localizations.dart';
import '../date_formatter.dart';

void showUpdateBudgetBottomSheet(BuildContext parentContext, Budget budget) {
  final t = AppLocalizations.of(parentContext);
  showModalBottomSheet(
    context: parentContext,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (BuildContext sheetContext) {
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
                        t.translate('update_budget'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(sheetContext),
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
                      selectionType.name,
                      style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${selectionType.updateDescription(budget.category!.categoryName)} '
                      '${selectionType == BudgetSelectionType.single ? '(${formatMonthYear(sheetContext, budget.budgetDate!)})' : ''}',
                      style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded, size: 24.0),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.of(parentContext).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: parentContext.read<CategoryBloc>(),
                            child: UpdateBudgetPage(budget: budget, budgetSelectionType: selectionType),
                          ),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
              ),
            ],
          ),
        ),
      );
    },
  );
}
