import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16.0, right: 12.0),
        title: Text(category.categoryName),
        trailing: IconButton(
          icon: const FaIcon(FontAwesomeIcons.squareMinus),
          onPressed: () async {
            final bool? confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(t.translate('delete_category')),
                content: Text(
                  '${t.translate('would_you_like_the_category')} "${category.categoryName}" ${t.translate('really_delete')}?',
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(t.translate('no')),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(t.translate('yes')),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              context.read<CategoryBloc>().add(DeleteCategory(categoryId: category.id!));
            }
          },
        ),
      ),
    );
  }
}
