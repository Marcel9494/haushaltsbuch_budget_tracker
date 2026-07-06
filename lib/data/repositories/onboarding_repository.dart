import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../enums/category_type.dart';
import '../models/onboarding_category.dart';

class OnboardingRepository {
  List<OnboardingCategory> loadExpensesStartCategories(BuildContext context) {
    final t = AppLocalizations.of(context);
    return [
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
    ];
  }
}
