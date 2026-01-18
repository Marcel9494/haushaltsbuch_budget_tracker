import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/core/consts/route_consts.dart';
import 'package:haushaltsbuch_budget_tracker/core/page_arguments/update_category_page_arguments.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/dialogs/show_delete_dialog.dart';

import '../../../../../blocs/category/category_bloc.dart';
import '../../../../../blocs/category/category_event.dart';
import '../../../../../data/models/category.dart';
import '../../../../../l10n/app_localizations.dart';

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, updateCategoryRoute, arguments: UpdateCategoryPageArguments(category)),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 16.0, right: 12.0),
          title: Text(category.categoryName),
          trailing: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareMinus),
            onPressed: () async {
              final bool confirmed = await showDeleteDialog(
                context,
                'delete_category',
                '${t.translate('would_you_like_the_category')} "${category.categoryName}" ${t.translate('really_delete')}?',
              );
              if (confirmed == true) {
                context.read<CategoryBloc>().add(DeleteCategory(categoryId: category.id!));
              }
            },
          ),
        ),
      ),
    );
  }
}
