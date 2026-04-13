import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/features/home/presentation/widgets/cards/guest_info_card.dart';
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
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';
import '../widgets/cards/home_grid_item_card.dart';
import '../widgets/charts/category_stats.dart';

class HomeContentPage extends StatefulWidget {
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;
  final ValueChanged<PeriodOfTimeType>? onPeriodOfTimeChanged;

  const HomeContentPage({
    super.key,
    required this.currentSelectedDate,
    required this.currentPeriodOfTimeType,
    required this.onPeriodOfTimeChanged,
  });

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  final ScrollController _controller = ScrollController();
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      setState(() {
        // 152 = item width + padding (z.B. 140 + 12)
        _currentPage = _controller.offset / 152;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
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
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                          child: SubtitleText(text: 'overview'),
                        ),
                        SizedBox(
                          height: 120.0,
                          child: ListView.builder(
                            controller: _controller,
                            scrollDirection: Axis.horizontal,
                            itemCount: generalDashboardElement.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: HomeGridItemCard(
                                  icon: FaIcon(getDashboardElementIcon(generalDashboardElement[index]!.icon), size: 20.0),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                          child: SubtitleText(text: 'monthly_values'),
                        ),
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
                                  icon: FaIcon(getDashboardElementIcon(element!.icon), size: 20.0),
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
                          onPeriodOfTimeChanged: widget.onPeriodOfTimeChanged,
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
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                          child: SubtitleText(text: 'overview'),
                        ),
                        SizedBox(
                          height: 120.0,
                          child: ListView.builder(
                            controller: _controller,
                            scrollDirection: Axis.horizontal,
                            itemCount: generalDashboardElement.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: HomeGridItemCard(
                                  icon: FaIcon(getDashboardElementIcon(generalDashboardElement[index]!.icon), size: 20.0),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                          child: SubtitleText(text: 'yearly_values'),
                        ),
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
                              for (final element in yearlyDashboardElements)
                                HomeGridItemCard(
                                  icon: FaIcon(getDashboardElementIcon(element!.icon), size: 20.0),
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
                          onPeriodOfTimeChanged: widget.onPeriodOfTimeChanged,
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
                return SizedBox.shrink();
              },
            );
          },
        );
      },
    );
  }
}
