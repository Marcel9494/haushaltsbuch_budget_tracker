import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/category_repository.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../blocs/category/category_bloc.dart';
import '../../../../blocs/category/category_event.dart';
import '../../../../blocs/category/category_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../data/models/category.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';
import '../../data/enums/category_type.dart';
import '../widgets/cards/category_card.dart';
import 'create_category_page.dart';

class CategoryListPage extends StatefulWidget {
  final CategoryType categoryType;

  const CategoryListPage({
    super.key,
    required this.categoryType,
  });

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> with SingleTickerProviderStateMixin {
  late CategoryType _selectedCategoryType = widget.categoryType;
  Key _expenseListKey = UniqueKey();
  Key _revenueListKey = UniqueKey();
  bool _ascendingOrder = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = _selectedCategoryType == CategoryType.expenses ? 0 : 1;
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      create: (context) => CategoryBloc(CategoryRepository())..add(LoadCategories()),
      child: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(t.translate('categories')),
            actions: [
              IconButton(
                icon: FaIcon(_ascendingOrder ? FontAwesomeIcons.arrowDownAZ : FontAwesomeIcons.arrowUpZA),
                onPressed: () {
                  setState(() {
                    _ascendingOrder = !_ascendingOrder;
                    _expenseListKey = UniqueKey();
                    _revenueListKey = UniqueKey();
                  });
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
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
          ),
          body: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoading) {
                return CircularLoadingIndicator();
              } else if (state is CategoryListLoaded) {
                List<Category> expenseCategories = state.categories
                    .where((category) => category.categoryType.name.contains(CategoryType.expenses.name))
                    .toList()
                  ..sort((a, b) => a.categoryName.toLowerCase().compareTo(b.categoryName.toLowerCase()));
                List<Category> revenueCategories = state.categories
                    .where((category) => category.categoryType.name.contains(CategoryType.revenue.name))
                    .toList()
                  ..sort((a, b) => a.categoryName.toLowerCase().compareTo(b.categoryName.toLowerCase()));
                if (_ascendingOrder == false) {
                  expenseCategories = expenseCategories.reversed.toList();
                  revenueCategories = revenueCategories.reversed.toList();
                }
                return TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    AnimationLimiter(
                      key: _expenseListKey,
                      child: ListView.builder(
                        itemCount: expenseCategories.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: listAnimationDurationInMs),
                            child: SlideAnimation(
                              verticalOffset: 40.0,
                              child: FadeInAnimation(
                                child: CategoryCard(category: expenseCategories[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    AnimationLimiter(
                      key: _revenueListKey,
                      child: ListView.builder(
                        itemCount: revenueCategories.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: listAnimationDurationInMs),
                            child: SlideAnimation(
                              verticalOffset: 40.0,
                              child: FadeInAnimation(
                                child: CategoryCard(category: revenueCategories[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else if (state is CategoryError) {
                return ErrorText(errorMessage: state.message);
              }
              return SizedBox.shrink();
            },
          ),
          floatingActionButton: OpenContainer(
            transitionDuration: const Duration(milliseconds: 500),
            transitionType: ContainerTransitionType.fade,
            openBuilder: (context, _) => CreateCategoryPage(selectedCategoryType: _selectedCategoryType),
            closedElevation: 6,
            closedShape: const CircleBorder(),
            closedColor: Colors.cyanAccent,
            closedBuilder: (context, openContainer) {
              return Container(
                width: 56.0,
                height: 56.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.cyanAccent,
                      Color(0xFF00ACC1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: openContainer,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.black87,
                    size: 26.0,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
