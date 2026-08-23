import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/features/dashboard/presentation/widgets/cards/guest_info_card.dart';

import '../../../../blocs/account/account_bloc.dart';
import '../../../../blocs/account/account_state.dart';
import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../blocs/budget/budget_bloc.dart';
import '../../../../blocs/budget/budget_event.dart';
import '../../../../blocs/budget/budget_state.dart';
import '../../../../blocs/dashboard_element/dashboard_element_bloc.dart';
import '../../../../blocs/dashboard_element/dashboard_element_state.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../data/enums/dashboard_element_type.dart';
import '../../../../data/enums/period_of_time_type.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/models/dashboard_element.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/repositories/budget_repository.dart';
import '../../../dashboard/presentation/widgets/cards/home_grid_item_card.dart';
import '../../../dashboard/presentation/widgets/charts/category_stats.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';
import '../../../shared/presentation/widgets/deco/expansion_tile.dart';

class DashboardPage extends StatefulWidget {
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;
  final bool categoryTileExpanded;
  final ValueChanged<bool>? onCategoryTileExpandedChanged;
  final bool generalOverviewTileExpanded;
  final ValueChanged<bool>? onGeneralOverviewTileExpandedChanged;
  final bool periodOverviewTileExpanded;
  final ValueChanged<bool>? onPeriodOverviewTileExpandedChanged;

  const DashboardPage({
    super.key,
    required this.currentSelectedDate,
    required this.currentPeriodOfTimeType,
    required this.categoryTileExpanded,
    required this.onCategoryTileExpandedChanged,
    required this.generalOverviewTileExpanded,
    required this.onGeneralOverviewTileExpandedChanged,
    required this.periodOverviewTileExpanded,
    required this.onPeriodOverviewTileExpandedChanged,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final CarouselSliderController _carouselSliderController = CarouselSliderController();
  int _currentGeneralDashboardElementIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          key: ValueKey('${widget.currentPeriodOfTimeType}_${widget.currentSelectedDate}'),
          create: (_) => BookingBloc(BookingRepository(), AccountRepository())
            ..add(widget.currentPeriodOfTimeType == PeriodOfTimeType.monthly
                ? LoadMonthlyBookings(selectedDate: widget.currentSelectedDate)
                : LoadYearlyBookings(selectedYear: widget.currentSelectedDate.year)),
        ),
        BlocProvider(
          create: (_) => BudgetBloc(BudgetRepository())
            ..add(widget.currentPeriodOfTimeType == PeriodOfTimeType.monthly
                ? LoadMonthlyBudgets(widget.currentSelectedDate)
                : LoadYearlyBudgets(widget.currentSelectedDate.year)),
        ),
      ],
      child: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, accountState) {
          return BlocBuilder<DashboardElementBloc, DashboardElementState>(
            builder: (context, dashboardElementState) {
              return BlocBuilder<BudgetBloc, BudgetState>(
                builder: (context, budgetState) {
                  return BlocBuilder<BookingBloc, BookingState>(
                    builder: (context, bookingState) {
                      if (bookingState is BookingLoading ||
                          accountState is AccountLoading ||
                          dashboardElementState is DashboardElementLoading ||
                          budgetState is BudgetLoading) {
                        return CircularLoadingIndicator();
                      } else if (bookingState is BookingListLoaded &&
                          accountState is AccountListLoaded &&
                          dashboardElementState is DashboardUserElementsLoaded &&
                          budgetState is BudgetListLoaded) {
                        List<DashboardElement?> generalDashboardElement = dashboardElementState.userDashboardElements
                            .where((element) => element.dashboardElementType == DashboardElementType.general)
                            .toList()
                          ..sort((a, b) => a.position!.compareTo(b.position!));
                        List<DashboardElement?> monthlyDashboardElements = dashboardElementState.userDashboardElements
                            .where((element) => element.dashboardElementType == DashboardElementType.month)
                            .toList()
                          ..sort((a, b) => a.position!.compareTo(b.position!));
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GuestInfoCard(),
                              SizedBox(height: 6.0),
                              DashboardExpansionTile(
                                icon: Icons.pie_chart_outline,
                                title: 'categories',
                                subtitle: 'expenses_and_revenue_by_categories',
                                context: context,
                                expanded: widget.categoryTileExpanded,
                                onExpansionChanged: widget.onCategoryTileExpandedChanged,
                                child: CategoryStats(
                                  bookings: bookingState.bookings,
                                  currentSelectedDate: widget.currentSelectedDate,
                                  currentPeriodOfTimeType: widget.currentPeriodOfTimeType,
                                ),
                              ),
                              generalDashboardElement.isEmpty
                                  ? SizedBox.shrink()
                                  : DashboardExpansionTile(
                                      icon: Icons.dashboard_outlined,
                                      title: 'overview',
                                      subtitle: 'your_key_financial_metrics',
                                      context: context,
                                      expanded: widget.generalOverviewTileExpanded,
                                      onExpansionChanged: widget.onGeneralOverviewTileExpandedChanged,
                                      child: Column(
                                        children: [
                                          CarouselSlider(
                                            items: generalDashboardElement.asMap().entries.map((entry) {
                                              final item = entry.value!;

                                              return HomeGridItemCard(
                                                icon: FaIcon(
                                                  getDashboardElementIcon(item.icon),
                                                  size: 18.0,
                                                  color: Colors.grey,
                                                ),
                                                title: item.title,
                                                stat: DashboardElement.calculateDisplayValue(
                                                    item, bookingState.bookings, accountState.accounts, budgetState.budgets),
                                                subtitle: item.shortDescription,
                                              );
                                            }).toList(),
                                            carouselController: _carouselSliderController,
                                            options: CarouselOptions(
                                                aspectRatio: 1.0,
                                                height: 120.0,
                                                viewportFraction: 0.5,
                                                initialPage: 0,
                                                enableInfiniteScroll: false,
                                                padEnds: false,
                                                scrollDirection: Axis.horizontal,
                                                onPageChanged: (index, reason) {
                                                  setState(() {
                                                    _currentGeneralDashboardElementIndex = index;
                                                  });
                                                }),
                                          ),
                                          generalDashboardElement.length >= 3
                                              ? Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: generalDashboardElement.asMap().entries.map((entry) {
                                                      final isActive = _currentGeneralDashboardElementIndex == entry.key;
                                                      return GestureDetector(
                                                        onTap: () => _carouselSliderController.animateToPage(entry.key),
                                                        child: Container(
                                                          width: 10.0,
                                                          height: 10.0,
                                                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: isActive ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.4),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                )
                                              : SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                              monthlyDashboardElements.isEmpty
                                  ? SizedBox.shrink()
                                  : DashboardExpansionTile(
                                      icon: Icons.calendar_month_outlined,
                                      title: 'monthly_values',
                                      subtitle: 'your_monthly_financial_overview',
                                      context: context,
                                      expanded: widget.periodOverviewTileExpanded,
                                      onExpansionChanged: widget.onPeriodOverviewTileExpandedChanged,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                            child: GridView.count(
                                              crossAxisCount: 2,
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              mainAxisSpacing: 16,
                                              crossAxisSpacing: 6,
                                              childAspectRatio: 1.6,
                                              children: [
                                                for (final element in monthlyDashboardElements)
                                                  HomeGridItemCard(
                                                    icon: FaIcon(
                                                      getDashboardElementIcon(element!.icon),
                                                      size: 18.0,
                                                      color: Colors.grey,
                                                    ),
                                                    title: element.title,
                                                    stat: DashboardElement.calculateDisplayValue(
                                                        element, bookingState.bookings, accountState.accounts, budgetState.budgets),
                                                    subtitle: element.shortDescription,
                                                  ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 64.0),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        );
                      } else if (bookingState is YearlyBookingListLoaded &&
                          accountState is AccountListLoaded &&
                          dashboardElementState is DashboardUserElementsLoaded &&
                          budgetState is YearlyBudgetListLoaded) {
                        List<Booking> yearlyBookings = bookingState.yearlyBookings.values.expand((bookingList) => bookingList).toList();
                        List<DashboardElement?> generalDashboardElement = dashboardElementState.userDashboardElements
                            .where((element) => element.dashboardElementType == DashboardElementType.general)
                            .toList()
                          ..sort((a, b) => a.position!.compareTo(b.position!));
                        List<DashboardElement?> yearlyDashboardElements = dashboardElementState.userDashboardElements
                            .where((element) => element.dashboardElementType == DashboardElementType.year)
                            .toList()
                          ..sort((a, b) => a.position!.compareTo(b.position!));
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GuestInfoCard(),
                              SizedBox(height: 6.0),
                              DashboardExpansionTile(
                                icon: Icons.pie_chart_outline,
                                title: 'categories',
                                subtitle: 'expenses_and_revenue_by_categories',
                                context: context,
                                expanded: widget.categoryTileExpanded,
                                onExpansionChanged: widget.onCategoryTileExpandedChanged,
                                child: CategoryStats(
                                  bookings: yearlyBookings,
                                  currentSelectedDate: widget.currentSelectedDate,
                                  currentPeriodOfTimeType: widget.currentPeriodOfTimeType,
                                ),
                              ),
                              generalDashboardElement.isEmpty
                                  ? SizedBox.shrink()
                                  : DashboardExpansionTile(
                                      icon: Icons.dashboard_outlined,
                                      title: 'overview',
                                      subtitle: 'your_key_financial_metrics',
                                      context: context,
                                      expanded: widget.generalOverviewTileExpanded,
                                      onExpansionChanged: widget.onGeneralOverviewTileExpandedChanged,
                                      child: Column(
                                        children: [
                                          CarouselSlider(
                                            items: generalDashboardElement.asMap().entries.map((entry) {
                                              final item = entry.value!;

                                              return HomeGridItemCard(
                                                icon: FaIcon(
                                                  getDashboardElementIcon(item.icon),
                                                  size: 18.0,
                                                  color: Colors.grey,
                                                ),
                                                title: item.title,
                                                stat: DashboardElement.calculateDisplayValue(item, yearlyBookings, accountState.accounts,
                                                    budgetState.yearlyBudgets.values.expand((budgetList) => budgetList).toList()),
                                                subtitle: item.shortDescription,
                                              );
                                            }).toList(),
                                            carouselController: _carouselSliderController,
                                            options: CarouselOptions(
                                                aspectRatio: 1.0,
                                                height: 120.0,
                                                viewportFraction: 0.5,
                                                initialPage: 0,
                                                enableInfiniteScroll: false,
                                                padEnds: false,
                                                scrollDirection: Axis.horizontal,
                                                onPageChanged: (index, reason) {
                                                  setState(() {
                                                    _currentGeneralDashboardElementIndex = index;
                                                  });
                                                }),
                                          ),
                                          generalDashboardElement.length >= 3
                                              ? Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: generalDashboardElement.asMap().entries.map((entry) {
                                                      final isActive = _currentGeneralDashboardElementIndex == entry.key;
                                                      return GestureDetector(
                                                        onTap: () => _carouselSliderController.animateToPage(entry.key),
                                                        child: Container(
                                                          width: 10.0,
                                                          height: 10.0,
                                                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: isActive ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.4),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                )
                                              : SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                              yearlyDashboardElements.isEmpty
                                  ? SizedBox.shrink()
                                  : DashboardExpansionTile(
                                      icon: Icons.pie_chart_outline,
                                      title: 'yearly_values',
                                      subtitle: 'your_yearly_financial_overview',
                                      context: context,
                                      expanded: widget.periodOverviewTileExpanded,
                                      onExpansionChanged: widget.onPeriodOverviewTileExpandedChanged,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                        child: GridView.count(
                                          crossAxisCount: 2,
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          mainAxisSpacing: 16,
                                          crossAxisSpacing: 6,
                                          childAspectRatio: 1.6,
                                          children: [
                                            for (final element in yearlyDashboardElements)
                                              HomeGridItemCard(
                                                icon: FaIcon(
                                                  getDashboardElementIcon(element!.icon),
                                                  size: 18.0,
                                                  color: Colors.grey,
                                                ),
                                                title: element.title,
                                                stat: DashboardElement.calculateDisplayValue(element, yearlyBookings, accountState.accounts,
                                                    budgetState.yearlyBudgets.values.expand((budgetList) => budgetList).toList()),
                                                subtitle: element.shortDescription,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                              SizedBox(height: 64.0),
                            ],
                          ),
                        );
                      } else if (bookingState is BookingError) {
                        return ErrorText(errorMessage: bookingState.message);
                      } else if (accountState is AccountError) {
                        return ErrorText(errorMessage: accountState.message);
                      } else if (dashboardElementState is DashboardElementError) {
                        return ErrorText(errorMessage: dashboardElementState.message);
                      }
                      return CircularLoadingIndicator();
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
