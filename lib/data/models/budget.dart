import 'category.dart';

class Budget {
  final String? id;
  final String? userId;
  final String categoryId;
  final Category? category;
  final double budgetAmount;

  Budget({
    this.id,
    this.userId,
    required this.categoryId,
    this.category,
    required this.budgetAmount,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      userId: map['user_id'],
      categoryId: map['category_id'],
      category: map['categories'] != null ? Category.fromMap(map['categories']) : null,
      budgetAmount: map['budget_amount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'budget_amount': budgetAmount,
    };
  }
}
