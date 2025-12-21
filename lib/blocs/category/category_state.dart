import '../../data/models/category.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryCreated extends CategoryState {
  final Category category;
  CategoryCreated(this.category);
}

class CategoryLoading extends CategoryState {}

class CategoryListLoaded extends CategoryState {
  final List<Category> categories;
  CategoryListLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}
