import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/category.dart';
import '../../data/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc(this._categoryRepository) : super(CategoryInitial()) {
    on<CreateCategory>(_onCreateCategory);
    on<LoadCategories>(_onLoadCategories);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onCreateCategory(CreateCategory event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final Category createdCategory = await _categoryRepository.createCategory(event.category);
      emit(CategoryCreated(createdCategory));
    } catch (e) {
      if (e.toString().contains('duplicated_category')) {
        emit(CategoryError('duplicated_category_error'));
      } else {
        emit(CategoryError('create_category_error'));
      }
    }
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final List<Category> categories = await _categoryRepository.loadCategories();
      emit(CategoryListLoaded(categories));
    } catch (e) {
      emit(CategoryError('load_categories_error'));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      Category updatedCategory = await _categoryRepository.updateCategory(event.category);
      emit(CategoryUpdated(updatedCategory));
    } catch (e) {
      if (e.toString().contains('duplicated_category')) {
        emit(CategoryError('duplicated_category_error'));
      } else {
        emit(CategoryError('update_category_error'));
      }
    }
  }

  Future<void> _onDeleteCategory(DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await _categoryRepository.deleteCategory(event.categoryId);
      final categories = await _categoryRepository.loadCategories();
      emit(CategoryListLoaded(categories));
    } catch (e) {
      emit(CategoryError('delete_category_error'));
    }
  }
}
