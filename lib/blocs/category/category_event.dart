import '../../data/models/category.dart';

abstract class CategoryEvent {}

class CreateCategory extends CategoryEvent {
  final Category category;

  CreateCategory({
    required this.category,
  });
}

class LoadCategories extends CategoryEvent {
  LoadCategories();
}

class DeleteCategory extends CategoryEvent {
  final String categoryId;

  DeleteCategory({
    required this.categoryId,
  });
}
