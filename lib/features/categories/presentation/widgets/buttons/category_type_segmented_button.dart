import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../data/enums/category_type.dart';

class CategoryTypeSegmentedButton extends StatefulWidget {
  CategoryType categoryType;
  final ValueChanged<CategoryType> onChanged;

  CategoryTypeSegmentedButton({
    super.key,
    required this.categoryType,
    required this.onChanged,
  });

  @override
  State<CategoryTypeSegmentedButton> createState() => _CategoryTypeSegmentedButtonState();
}

class _CategoryTypeSegmentedButtonState extends State<CategoryTypeSegmentedButton> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<CategoryType>(
        segments: <ButtonSegment<CategoryType>>[
          ButtonSegment<CategoryType>(
            value: CategoryType.expenses,
            label: Text(t.translate('expense')),
            icon: Icon(Icons.remove_rounded),
          ),
          ButtonSegment<CategoryType>(
            value: CategoryType.revenue,
            label: Text(t.translate('income')),
            icon: Icon(Icons.add_rounded),
          ),
        ],
        selected: <CategoryType>{widget.categoryType},
        onSelectionChanged: (Set<CategoryType> newCategoryTypeSelection) {
          setState(() {
            widget.categoryType = newCategoryTypeSelection.first;
          });
          widget.onChanged(newCategoryTypeSelection.first);
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.cyanAccent.withAlpha(60);
            }
            return null;
          }),
        ),
      ),
    );
  }
}
