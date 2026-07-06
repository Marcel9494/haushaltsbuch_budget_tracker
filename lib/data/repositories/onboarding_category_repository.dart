import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../enums/category_type.dart';
import '../models/onboarding_category.dart';

class OnboardingCategoryRepository {
  List<OnboardingCategory> loadOnboardingCategories(BuildContext context) {
    final t = AppLocalizations.of(context);
    return [
      // Onboarding Ausgabenkategorien
      OnboardingCategory(categoryName: t.translate('groceries'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('household_goods'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('rent'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('additional_costs'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('education'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('clothing'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('sports'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('leisure'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('gifts'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('donation'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('restaurant'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('mobility'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('subscription'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('technology'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('vacation'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('beauty'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('credit'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('other'), categoryType: CategoryType.expense, isSelected: true),
      OnboardingCategory(categoryName: t.translate('pub'), categoryType: CategoryType.expense, isSelected: false),
      OnboardingCategory(categoryName: t.translate('pets'), categoryType: CategoryType.expense, isSelected: false),
      OnboardingCategory(categoryName: t.translate('furniture'), categoryType: CategoryType.expense, isSelected: false),
      // Onboarding Einnahmekategorien
      OnboardingCategory(categoryName: t.translate('salary'), categoryType: CategoryType.income, isSelected: true),
      OnboardingCategory(categoryName: t.translate('interest'), categoryType: CategoryType.income, isSelected: true),
      OnboardingCategory(categoryName: t.translate('christmas_bonus'), categoryType: CategoryType.income, isSelected: true),
      OnboardingCategory(categoryName: t.translate('vacation_bonus'), categoryType: CategoryType.income, isSelected: true),
      OnboardingCategory(categoryName: t.translate('other'), categoryType: CategoryType.income, isSelected: true),
      OnboardingCategory(categoryName: t.translate('bonus'), categoryType: CategoryType.income, isSelected: false),
      OnboardingCategory(categoryName: t.translate('dividends'), categoryType: CategoryType.income, isSelected: false),
      OnboardingCategory(categoryName: t.translate('rental_income'), categoryType: CategoryType.income, isSelected: false),
      OnboardingCategory(categoryName: t.translate('additional_income'), categoryType: CategoryType.income, isSelected: false),
      OnboardingCategory(categoryName: t.translate('profit_sharing_bonus'), categoryType: CategoryType.income, isSelected: false),
      OnboardingCategory(categoryName: t.translate('tax_refund'), categoryType: CategoryType.income, isSelected: false),
    ];
  }

  Future<List<OnboardingCategory>> addOnboardingCategory(List<OnboardingCategory> onboardingCategories, OnboardingCategory onboardingCategory) async {
    if (onboardingCategories.any((category) =>
        category.categoryName.toLowerCase() == onboardingCategory.categoryName.toLowerCase() &&
        category.categoryType == onboardingCategory.categoryType)) {
      throw Exception('duplicated_onboarding_category');
    }
    onboardingCategories.add(onboardingCategory);
    return onboardingCategories;
  }

  Future<List<OnboardingCategory>> selectOnboardingCategory(
      List<OnboardingCategory> onboardingCategories, OnboardingCategory updatingOnboardingCategory) {
    final index = onboardingCategories.indexWhere((category) =>
        category.categoryName.toLowerCase() == updatingOnboardingCategory.categoryName.toLowerCase() &&
        category.categoryType == updatingOnboardingCategory.categoryType);
    onboardingCategories[index].isSelected = !onboardingCategories[index].isSelected;
    return Future.value(onboardingCategories);
  }
}
