part of 'onboarding_category_bloc.dart';

sealed class OnboardingCategoryState {}

final class OnboardingCategoryInitial extends OnboardingCategoryState {}

class OnboardingCategoryLoading extends OnboardingCategoryState {
  OnboardingCategoryLoading();
}

class OnboardingCategoryAdded extends OnboardingCategoryState {
  final List<OnboardingCategory> onboardingCategories;
  OnboardingCategoryAdded(this.onboardingCategories);
}

class OnboardingCategoriesLoaded extends OnboardingCategoryState {
  final List<OnboardingCategory> onboardingCategories;
  OnboardingCategoriesLoaded(this.onboardingCategories);
}

class OnboardingCategoryError extends OnboardingCategoryState {
  final String message;
  OnboardingCategoryError(this.message);
}
