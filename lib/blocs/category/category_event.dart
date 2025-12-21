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
