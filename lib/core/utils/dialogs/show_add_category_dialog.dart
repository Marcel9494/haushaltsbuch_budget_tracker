import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/input_fields/title_input_field.dart';

import '../../../l10n/app_localizations.dart';

Future<bool> showAddCategoryDialog(
  BuildContext context,
  TextEditingController categorieNameController,
  Future<void> Function(String categoryName) onCreate,
) async {
  final t = AppLocalizations.of(context);
  categorieNameController.text = '';
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.translate('create_category')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.translate('create_category_text')),
          SizedBox(height: 12.0),
          TitleInputField(
            titleController: categorieNameController,
            text: t.translate('category_name'),
            showTitle: false,
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(t.translate('cancel')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black87,
            backgroundColor: Colors.cyanAccent,
          ),
          onPressed: () async {
            final name = categorieNameController.text;
            await onCreate(name);
            Navigator.of(context).pop(true);
          },
          child: Text(t.translate('create')),
        ),
      ],
    ),
  );
  return confirmed!;
}
