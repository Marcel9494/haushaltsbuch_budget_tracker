import 'category.dart';

class Budget {
  final String? id;
  final String? budgetId;
  final String? userId;
  final String categoryId;
  final Category? category;
  final double budgetAmount;
  final DateTime? budgetDate;

  Budget({
    this.id,
    this.budgetId,
    this.userId,
    required this.categoryId,
    this.category,
    required this.budgetAmount,
    this.budgetDate,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      budgetId: map['budget_id'],
      userId: map['user_id'],
      categoryId: map['category_id'],
      category: map['categories'] != null ? Category.fromMap(map['categories']) : null,
      budgetAmount: map['budget_amount'],
      budgetDate: DateTime.parse(map['budget_date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'budget_id': budgetId,
      'user_id': userId,
      'category_id': categoryId,
      'budget_amount': budgetAmount,
      'budget_date': budgetDate?.toIso8601String(),
    };
  }
}
