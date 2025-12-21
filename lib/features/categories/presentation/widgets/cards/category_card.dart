import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../data/models/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16.0, right: 12.0),
        title: Text(category.categoryName),
        trailing: IconButton(
          icon: FaIcon(FontAwesomeIcons.squareMinus),
          onPressed: () {},
        ),
      ),
    );
  }
}
