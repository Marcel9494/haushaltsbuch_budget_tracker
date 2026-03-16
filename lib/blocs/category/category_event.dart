import '../../data/models/category.dart';

abstract class CategoryEvent {}

class CreateCategory extends CategoryEvent {
  final Category category;

  CreateCategory({
    required this.category,
  });
}

class CreateCategories extends CategoryEvent {
  final List<Category> categories;

  CreateCategories({
    required this.categories,
  });
}

class LoadCategories extends CategoryEvent {
  LoadCategories();
}

class UpdateCategory extends CategoryEvent {
  final Category category;

  UpdateCategory({
    required this.category,
  });
}

class DeleteCategory extends CategoryEvent {
  final String categoryId;

  DeleteCategory({
    required this.categoryId,
  });
}
