import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:haushaltsbuch_budget_tracker/core/consts/route_consts.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/dialogs/show_add_category_dialog.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/onboarding_progressbar_type.dart';
import 'package:haushaltsbuch_budget_tracker/features/onboarding/presentation/widgets/cards/onboarding_description_card.dart';

import '../../../../core/consts/animation_consts.dart';
import '../../../../data/helper_models/onboarding_models.dart';
import '../../../../data/helper_models/start_category.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/buttons/add_button.dart';
import '../../../categories/data/enums/category_type.dart';
import '../widgets/cards/selectable_category_card.dart';
import '../widgets/deco/onboarding_progress_bar.dart';
import '../widgets/navigation/onboarding_navigation.dart';

class CategoryOnboardingPage extends StatefulWidget {
  const CategoryOnboardingPage({super.key});

  @override
  State<CategoryOnboardingPage> createState() => _CategoryOnboardingPageState();
}

class _CategoryOnboardingPageState extends State<CategoryOnboardingPage> with SingleTickerProviderStateMixin {
  late CategoryType _selectedCategoryType = CategoryType.expenses;
  late TabController _tabController;
  final TextEditingController _categorieNameController = TextEditingController();
  final ScrollController _expensesScrollController = ScrollController();
  final ScrollController _revenueScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 0;
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {
          if (_tabController.index == 0) {
            _selectedCategoryType = CategoryType.expenses;
          } else {
            _selectedCategoryType = CategoryType.revenue;
          }
        });
      }
    });
  }

  void createNewStartCategory(String categoryName) {
    setState(() {
      if (_selectedCategoryType == CategoryType.expenses) {
        if (expensesStartCategories.any((category) => category.categoryName == categoryName)) {
          expensesStartCategories.firstWhere((category) => category.categoryName == categoryName).isSelected = true;
        } else {
          expensesStartCategories.add(StartCategory(categoryName: categoryName, categoryType: CategoryType.expenses, isSelected: true));
          _scrollToListEnd();
        }
      } else {
        if (revenueStartCategories.any((category) => category.categoryName == categoryName)) {
          revenueStartCategories.firstWhere((category) => category.categoryName == categoryName).isSelected = true;
        } else {
          revenueStartCategories.add(StartCategory(categoryName: categoryName, categoryType: CategoryType.revenue, isSelected: true));
          _scrollToListEnd();
        }
      }
    });
  }

  void _scrollToListEnd() {
    final controller = _selectedCategoryType == CategoryType.expenses ? _expensesScrollController : _revenueScrollController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        body: DefaultTabController(
          initialIndex: 0,
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingProgressBar(
                progressBar1State: OnboardingProgressbarType.active,
                progressBar2State: OnboardingProgressbarType.notCompleted,
                progressBar3State: OnboardingProgressbarType.notCompleted,
              ),
              OnboardingDescriptionCard(
                title: t.translate('select_categories'),
                descriptionText1: t.translate('select_categories_description'),
                descriptionText2: t.translate('change_categories_later'),
              ),
              TabBar(
                controller: _tabController,
                onTap: (index) {
                  setState(() {
                    _selectedCategoryType = index == 0 ? CategoryType.expenses : CategoryType.revenue;
                  });
                },
                tabs: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.remove_rounded),
                        SizedBox(width: 8.0),
                        Text(t.translate('expenses')),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded),
                        SizedBox(width: 8.0),
                        Text(t.translate('revenue')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    AnimationLimiter(
                      child: ListView.builder(
                        controller: _expensesScrollController,
                        itemCount: expensesStartCategories.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: listAnimationDurationInMs),
                            child: SlideAnimation(
                              verticalOffset: 40.0,
                              child: FadeInAnimation(
                                child: SelectableCategoryCard(
                                  category: expensesStartCategories[index],
                                  onPressed: () => setState(() {
                                    expensesStartCategories[index].isSelected = !expensesStartCategories[index].isSelected;
                                  }),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    AnimationLimiter(
                      child: ListView.builder(
                        controller: _revenueScrollController,
                        itemCount: revenueStartCategories.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: listAnimationDurationInMs),
                            child: SlideAnimation(
                              verticalOffset: 40.0,
                              child: FadeInAnimation(
                                child: SelectableCategoryCard(
                                  category: revenueStartCategories[index],
                                  onPressed: () => setState(() {
                                    revenueStartCategories[index].isSelected = !revenueStartCategories[index].isSelected;
                                  }),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.center,
                child: AddButton(
                  text: t.translate('create_additional_category'),
                  onPressed: () => showAddCategoryDialog(
                    context,
                    _categorieNameController,
                    (name) async {
                      createNewStartCategory(name);
                    },
                  ),
                ),
              ),
              OnboardingNavigation(
                nextRoute: dashboardOnboardingRoute,
                nextButtonText: 'continue',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
