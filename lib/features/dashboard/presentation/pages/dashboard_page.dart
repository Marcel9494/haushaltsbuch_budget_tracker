import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/features/dashboard/presentation/widgets/cards/guest_info_card.dart';
import 'package:haushaltsbuch_budget_tracker/features/shared/presentation/widgets/deco/subtitle_text.dart';

import '../../../../blocs/account/account_bloc.dart';
import '../../../../blocs/account/account_state.dart';
import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../blocs/dashboard_element/dashboard_element_bloc.dart';
import '../../../../blocs/dashboard_element/dashboard_element_state.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../data/enums/dashboard_element_type.dart';
import '../../../../data/enums/period_of_time_type.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/models/dashboard_element.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../dashboard/presentation/widgets/cards/home_grid_item_card.dart';
import '../../../dashboard/presentation/widgets/charts/category_stats.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';

class DashboardPage extends StatefulWidget {
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;

  const DashboardPage({
    super.key,
    required this.currentSelectedDate,
    required this.currentPeriodOfTimeType,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ScrollController _scrollController = ScrollController();
  final CarouselSliderController _carouselSliderController = CarouselSliderController();
  double _currentPage = 0.0;
  int _current = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {
        // 152 = item width + padding (z.B. 140 + 12)
        _currentPage = _scrollController.offset / 152;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey('${widget.currentPeriodOfTimeType}_${widget.currentSelectedDate}'),
      create: (_) => BookingBloc(BookingRepository(), AccountRepository())
        ..add(widget.currentPeriodOfTimeType == PeriodOfTimeType.monthly
            ? LoadMonthlyBookings(selectedDate: widget.currentSelectedDate)
            : LoadYearlyBookings(selectedYear: widget.currentSelectedDate.year)),
      child: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, accountState) {
          return BlocBuilder<DashboardElementBloc, DashboardElementState>(
            builder: (context, dashboardElementState) {
              return BlocBuilder<BookingBloc, BookingState>(
                builder: (context, bookingState) {
                  if (bookingState is BookingLoading || accountState is AccountLoading || dashboardElementState is DashboardElementLoading) {
                    return CircularLoadingIndicator();
                  } else if (bookingState is BookingListLoaded &&
                      accountState is AccountListLoaded &&
                      dashboardElementState is DashboardUserElementsLoaded) {
                    List<DashboardElement?> generalDashboardElement = dashboardElementState.userDashboardElements
                        .where((element) => element.dashboardElementType == DashboardElementType.general)
                        .toList();
                    List<DashboardElement?> monthlyDashboardElements = dashboardElementState.userDashboardElements
                        .where((element) => element.dashboardElementType == DashboardElementType.month)
                        .toList();
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GuestInfoCard(),
                          generalDashboardElement.isEmpty
                              ? SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                                  child: SubtitleText(text: 'overview'),
                                ),
                          generalDashboardElement.isEmpty
                              ? SizedBox.shrink()
                              : Column(
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
                                          stat: item.showValue,
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
                                              _current = index;
                                            });
                                          }),
                                    ),
                                    generalDashboardElement.length >= 3
                                        ? Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: generalDashboardElement.asMap().entries.map((entry) {
                                                final isActive = _current == entry.key;
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
                          monthlyDashboardElements.isEmpty
                              ? SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                                  child: SubtitleText(text: 'monthly_values'),
                                ),
                          monthlyDashboardElements.isEmpty
                              ? SizedBox.shrink()
                              : Padding(
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
                                          stat: DashboardElement.calculateDisplayValue(element, bookingState.bookings, accountState.accounts),
                                          subtitle: element.shortDescription,
                                        ),
                                    ],
                                  ),
                                ),
                          SizedBox(height: 20.0),
                          SubtitleText(text: 'categories'),
                          SizedBox(height: 12.0),
                          CategoryStats(
                            bookings: bookingState.bookings,
                            currentSelectedDate: widget.currentSelectedDate,
                            currentPeriodOfTimeType: widget.currentPeriodOfTimeType,
                          ),
                        ],
                      ),
                    );
                  } else if (bookingState is YearlyBookingListLoaded &&
                      accountState is AccountListLoaded &&
                      dashboardElementState is DashboardUserElementsLoaded) {
                    List<Booking> yearlyBookings = bookingState.yearlyBookings.values.expand((bookingList) => bookingList).toList();
                    List<DashboardElement?> generalDashboardElement = dashboardElementState.userDashboardElements
                        .where((element) => element.dashboardElementType == DashboardElementType.general)
                        .toList();
                    List<DashboardElement?> yearlyDashboardElements = dashboardElementState.userDashboardElements
                        .where((element) => element.dashboardElementType == DashboardElementType.year)
                        .toList();
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GuestInfoCard(),
                          generalDashboardElement.isEmpty
                              ? SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                                  child: SubtitleText(text: 'overview'),
                                ),
                          generalDashboardElement.isEmpty
                              ? SizedBox.shrink()
                              : SizedBox(
                                  height: 120.0,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: generalDashboardElement.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                        child: HomeGridItemCard(
                                          icon: FaIcon(
                                            getDashboardElementIcon(generalDashboardElement[index]!.icon),
                                            size: 18.0,
                                            color: Colors.grey,
                                          ),
                                          title: generalDashboardElement[index]!.title,
                                          stat: generalDashboardElement[index]!.showValue,
                                          subtitle: generalDashboardElement[index]!.shortDescription,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          generalDashboardElement.length >= 3
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: SizedBox(
                                    height: 16.0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(generalDashboardElement.length, (index) {
                                        int activeIndex = _currentPage.round().clamp(0, generalDashboardElement.length - 1);
                                        bool isActive = index == activeIndex;
                                        double difference = (_currentPage - index).abs();
                                        double value = (1 - difference).clamp(0.0, 1.0);
                                        return AnimatedContainer(
                                          duration: Duration(milliseconds: 0),
                                          margin: EdgeInsets.symmetric(horizontal: 4),
                                          width: 6 + (value * 4),
                                          height: 6 + (value * 4),
                                          decoration: BoxDecoration(
                                            color: isActive ? Colors.cyanAccent : Colors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                          yearlyDashboardElements.isEmpty
                              ? SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                                  child: SubtitleText(text: 'yearly_values'),
                                ),
                          yearlyDashboardElements.isEmpty
                              ? SizedBox.shrink()
                              : Padding(
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
                                          stat: DashboardElement.calculateDisplayValue(element, yearlyBookings, accountState.accounts),
                                          subtitle: element.shortDescription,
                                        ),
                                    ],
                                  ),
                                ),
                          SizedBox(height: 20.0),
                          SubtitleText(text: 'categories'),
                          SizedBox(height: 12.0),
                          CategoryStats(
                            bookings: yearlyBookings,
                            currentSelectedDate: widget.currentSelectedDate,
                            currentPeriodOfTimeType: widget.currentPeriodOfTimeType,
                          ),
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
      ),
    );
  }
}
