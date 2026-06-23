import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../data/models/onboarding_category.dart';
import '../../data/repositories/onboarding_category_repository.dart';

part 'onboarding_category_event.dart';
part 'onboarding_category_state.dart';

class OnboardingCategoryBloc extends Bloc<OnboardingCategoryEvent, OnboardingCategoryState> {
  final OnboardingCategoryRepository onboardingCategoryRepository;

  OnboardingCategoryBloc(this.onboardingCategoryRepository) : super(OnboardingCategoryInitial()) {
    on<LoadOnboardingCategories>(_onLoadOnboardingCategories);
    on<AddOnboardingCategory>(_onAddOnboardingCategory);
    on<SelectOnboardingCategory>(_onSelectOnboardingCategory);
  }

  Future<void> _onLoadOnboardingCategories(LoadOnboardingCategories event, Emitter<OnboardingCategoryState> emit) async {
    emit(OnboardingCategoryLoading());
    try {
      final List<OnboardingCategory> onboardingCategories = onboardingCategoryRepository.loadOnboardingCategories(event.context);
      emit(OnboardingCategoriesLoaded(onboardingCategories));
    } catch (e) {
      emit(OnboardingCategoryError('load_onboarding_categories_error'));
    }
  }

  Future<void> _onAddOnboardingCategory(AddOnboardingCategory event, Emitter<OnboardingCategoryState> emit) async {
    emit(OnboardingCategoryLoading());
    try {
      final List<OnboardingCategory> onboardingCategories =
          await onboardingCategoryRepository.addOnboardingCategory(event.onboardingCategories, event.onboardingCategory);
      emit(OnboardingCategoriesLoaded(onboardingCategories));
    } catch (e) {
      if (e.toString().contains('duplicated_onboarding_category')) {
        emit(OnboardingCategoryError('duplicated_onboarding_category_error'));
      } else {
        emit(OnboardingCategoryError('add_onboarding_category_error'));
      }
    }
  }

  Future<void> _onSelectOnboardingCategory(SelectOnboardingCategory event, Emitter<OnboardingCategoryState> emit) async {
    try {
      final List<OnboardingCategory> onboardingCategories =
          await onboardingCategoryRepository.selectOnboardingCategory(event.onboardingCategories, event.updatingOnboardingCategory);
      emit(OnboardingCategoriesLoaded(onboardingCategories));
    } catch (e) {
      if (e.toString().contains('duplicated_onboarding_category')) {
        emit(OnboardingCategoryError('duplicated_onboarding_category_error'));
      } else {
        emit(OnboardingCategoryError('select_onboarding_category_error'));
      }
    }
  }
}
