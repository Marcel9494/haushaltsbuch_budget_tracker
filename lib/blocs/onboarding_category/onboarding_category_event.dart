part of 'onboarding_category_bloc.dart';

sealed class OnboardingCategoryEvent {}

class LoadOnboardingCategories extends OnboardingCategoryEvent {
  BuildContext context;

  LoadOnboardingCategories({
    required this.context,
  });
}

class AddOnboardingCategory extends OnboardingCategoryEvent {
  List<OnboardingCategory> onboardingCategories;
  OnboardingCategory onboardingCategory;

  AddOnboardingCategory({
    required this.onboardingCategories,
    required this.onboardingCategory,
  });
}

class SelectOnboardingCategory extends OnboardingCategoryEvent {
  List<OnboardingCategory> onboardingCategories;
  OnboardingCategory updatingOnboardingCategory;

  SelectOnboardingCategory({
    required this.onboardingCategories,
    required this.updatingOnboardingCategory,
  });
}
