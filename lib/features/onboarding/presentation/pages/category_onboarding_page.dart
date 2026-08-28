import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:haushaltsbuch_budget_tracker/core/consts/route_consts.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/dialogs/show_add_category_dialog.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/onboarding_progressbar_type.dart';
import 'package:haushaltsbuch_budget_tracker/features/onboarding/presentation/widgets/cards/onboarding_description_card.dart';

import '../../../../blocs/onboarding_category/onboarding_category_bloc.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../data/enums/category_type.dart';
import '../../../../data/models/onboarding_category.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/buttons/add_button.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../widgets/cards/selectable_category_card.dart';
import '../widgets/deco/onboarding_progress_bar.dart';
import '../widgets/navigation/onboarding_navigation.dart';

class CategoryOnboardingPage extends StatefulWidget {
  const CategoryOnboardingPage({super.key});

  @override
  State<CategoryOnboardingPage> createState() => _CategoryOnboardingPageState();
}

class _CategoryOnboardingPageState extends State<CategoryOnboardingPage> with SingleTickerProviderStateMixin {
  late CategoryType _selectedCategoryType = CategoryType.expense;
  late TabController _tabController;
  final TextEditingController _categorieNameController = TextEditingController();
  final ScrollController _expensesScrollController = ScrollController();
  final ScrollController _incomeScrollController = ScrollController();
  List<OnboardingCategory> expensesStartCategories = [];
  List<OnboardingCategory> revenueStartCategories = [];

  @override
  void initState() {
    super.initState();
    context.read<OnboardingCategoryBloc>().add(LoadOnboardingCategories(context: context));
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 0;
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {
          if (_tabController.index == 0) {
            _selectedCategoryType = CategoryType.expense;
          } else {
            _selectedCategoryType = CategoryType.income;
          }
        });
      }
    });
  }

  void _scrollToListEnd() {
    final controller = _selectedCategoryType == CategoryType.expense ? _expensesScrollController : _incomeScrollController;
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
    return BlocBuilder<OnboardingCategoryBloc, OnboardingCategoryState>(
      builder: (context, state) {
        if (state is OnboardingCategoryLoading) {
          return CircularLoadingIndicator();
        } else if (state is OnboardingCategoriesLoaded) {
          List<OnboardingCategory> expenseOnboardingCategories =
              state.onboardingCategories.where((onboardingCategory) => onboardingCategory.categoryType.name == CategoryType.expense.name).toList();
          List<OnboardingCategory> incomeOnboardingCategories =
              state.onboardingCategories.where((onboardingCategory) => onboardingCategory.categoryType.name == CategoryType.income.name).toList();
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
                          _selectedCategoryType = index == 0 ? CategoryType.expense : CategoryType.income;
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
                              itemCount: expenseOnboardingCategories.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: listAnimationDurationInMs),
                                  child: SlideAnimation(
                                    verticalOffset: 40.0,
                                    child: FadeInAnimation(
                                      child: SelectableCategoryCard(
                                        category: expenseOnboardingCategories[index],
                                        onPressed: () => context.read<OnboardingCategoryBloc>().add(SelectOnboardingCategory(
                                              onboardingCategories: state.onboardingCategories,
                                              updatingOnboardingCategory: expenseOnboardingCategories[index],
                                            )),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          AnimationLimiter(
                            child: ListView.builder(
                              controller: _incomeScrollController,
                              itemCount: incomeOnboardingCategories.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: listAnimationDurationInMs),
                                  child: SlideAnimation(
                                    verticalOffset: 40.0,
                                    child: FadeInAnimation(
                                      child: SelectableCategoryCard(
                                        category: incomeOnboardingCategories[index],
                                        onPressed: () => context.read<OnboardingCategoryBloc>().add(SelectOnboardingCategory(
                                              onboardingCategories: state.onboardingCategories,
                                              updatingOnboardingCategory: incomeOnboardingCategories[index],
                                            )),
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
                            context.read<OnboardingCategoryBloc>().add(AddOnboardingCategory(
                                  onboardingCategories: state.onboardingCategories,
                                  onboardingCategory: OnboardingCategory(categoryName: name, categoryType: _selectedCategoryType, isSelected: true),
                                ));
                            _scrollToListEnd();
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
        } else if (state is OnboardingCategoryError) {
          return Center(child: Text(t.translate(state.message)));
        }
        return SizedBox.shrink();
      },
    );
  }
}
