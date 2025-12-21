import '../../features/categories/data/enums/category_type.dart';

class Category {
  final String? id;
  final String? userId;
  final String categoryName;
  final CategoryType categoryType;

  Category({
    this.id,
    this.userId,
    required this.categoryName,
    required this.categoryType,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      userId: map['user_id'],
      categoryName: map['category_name'],
      categoryType: CategoryType.fromString(map['category_type']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'category_name': categoryName,
      'category_type': categoryType.name,
    };
  }
}
