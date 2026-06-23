import '../enums/category_type.dart';

class OnboardingCategory {
  final String categoryName;
  final CategoryType categoryType;
  bool isSelected;

  OnboardingCategory({
    required this.categoryName,
    required this.categoryType,
    required this.isSelected,
  });

  factory OnboardingCategory.fromMap(Map<String, dynamic> map) {
    return OnboardingCategory(
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
