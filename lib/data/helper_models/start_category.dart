import '../../features/categories/data/enums/category_type.dart';

class StartCategory {
  final String categoryName;
  final CategoryType categoryType;
  bool isSelected;

  StartCategory({
    required this.categoryName,
    required this.categoryType,
    required this.isSelected,
  });

  factory StartCategory.fromMap(Map<String, dynamic> map) {
    return StartCategory(
      categoryName: map['category_name'],
      categoryType: CategoryType.fromString(map['category_type']),
      isSelected: map['is_selected'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category_name': categoryName,
      'category_type': categoryType.pluralName,
      'is_selected': isSelected,
    };
  }
}
