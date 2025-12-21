import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/core/consts/route_consts.dart';
import 'package:haushaltsbuch_budget_tracker/features/home/presentation/widgets/navigation/month_navigation.dart';
import 'package:haushaltsbuch_budget_tracker/features/home/presentation/widgets/navigation/year_navigation.dart';

import '../../../../blocs/account/account_bloc.dart';
import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../data/enums/period_of_time_type.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../accounts/presentation/pages/account_list_page.dart';
import '../../../bookings/presentation/pages/booking_list_page.dart';
import '../../../bookings/presentation/pages/create_booking_page.dart';
import 'home_content_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late BookingBloc _bookingBloc;
  DateTime _currentSelectedDate = DateTime.now();
  PeriodOfTimeType _currentPeriodOfTime = PeriodOfTimeType.monthly;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _bookingBloc = context.read<BookingBloc>();
    onPeriodOfTimeChanged(_currentPeriodOfTime);
  }

  void _loadMonthlyBookings(DateTime selectedDate) {
    _bookingBloc.add(
      LoadMonthlyBookings(
        selectedDate: selectedDate,
        userId: 'a39f32da-0876-4119-abf4-f636c2a8ad12',
      ),
    );
  }

  void _loadYearlyBookings(int selectedYear) {
    _bookingBloc.add(
      LoadYearlyBookings(
        selectedYear: selectedYear,
        userId: 'a39f32da-0876-4119-abf4-f636c2a8ad12',
      ),
    );
  }

  void onPeriodOfTimeChanged(PeriodOfTimeType newPeriodOfTime) {
    setState(() {
      _currentPeriodOfTime = newPeriodOfTime;
      if (_currentPeriodOfTime == PeriodOfTimeType.monthly) {
        _loadMonthlyBookings(_currentSelectedDate);
      } else {
        _loadYearlyBookings(_currentSelectedDate.year);
      }
    });
  }

  List<Widget> get _pages => [
        HomeContentPage(
          key: ValueKey(_currentSelectedDate),
          currentSelectedDate: _currentSelectedDate,
          currentPeriodOfTimeType: _currentPeriodOfTime,
          onPeriodOfTimeChanged: (newPeriodOfTime) {
            onPeriodOfTimeChanged(newPeriodOfTime);
          },
        ),
        BookingListPage(
          key: ValueKey(_currentSelectedDate),
          currentSelectedDate: _currentSelectedDate,
          currentPeriodOfTimeType: _currentPeriodOfTime,
          onPeriodOfTimeChanged: (newPeriodOfTime) {
            onPeriodOfTimeChanged(newPeriodOfTime);
          },
        ),
        BlocProvider(
          create: (context) => AccountBloc(AccountRepository()),
          child: AccountListPage(),
        ),
        HomeContentPage(
          currentSelectedDate: _currentSelectedDate,
          currentPeriodOfTimeType: _currentPeriodOfTime,
          onPeriodOfTimeChanged: (newPeriodOfTime) {
            setState(() {
              _currentPeriodOfTime = newPeriodOfTime;
            });
          },
        ),
        HomeContentPage(
          currentSelectedDate: _currentSelectedDate,
          currentPeriodOfTimeType: _currentPeriodOfTime,
          onPeriodOfTimeChanged: (newPeriodOfTime) {
            setState(() {
              _currentPeriodOfTime = newPeriodOfTime;
            });
          },
        ),
      ];
  final List<String> _pageTitle = [
    'home',
    'bookings',
    'accounts',
    'budgets',
    'goals',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate(_pageTitle[_selectedPageIndex]), style: TextStyle(fontSize: 20.0)),
        actions: [
          _currentPeriodOfTime == PeriodOfTimeType.monthly
              ? MonthNavigation(
                  initialDate: _currentSelectedDate,
                  onDateChanged: (newDate) {
                    setState(() {
                      _currentSelectedDate = newDate;
                      _loadMonthlyBookings(_currentSelectedDate);
                    });
                  },
                )
              : YearNavigation(
                  initialYear: _currentSelectedDate.year,
                  onYearChanged: (newYear) {
                    setState(() {
                      _currentSelectedDate = DateTime(newYear, 1, 1);
                      _loadYearlyBookings(_currentSelectedDate.year);
                    });
                  },
                ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 120.0,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.cyan),
                child: Text(t.translate('app_name')),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home_rounded),
              title: Text(t.translate('home')),
              onTap: () => {
                _onItemTapped(0),
                Navigator.pop(context),
              },
            ),
            ListTile(
              leading: Icon(Icons.menu_book_rounded),
              title: Text(t.translate('bookings')),
              onTap: () => {
                _onItemTapped(1),
                Navigator.pop(context),
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.buildingColumns, size: 22.0),
              title: Text(t.translate('accounts')),
              onTap: () => {
                _onItemTapped(2),
                Navigator.pop(context),
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet_rounded),
              title: Text(t.translate('budgets')),
              onTap: () => {
                _onItemTapped(3),
                Navigator.pop(context),
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.bullseye),
              title: Text(t.translate('goals')),
              onTap: () => {
                _onItemTapped(4),
                Navigator.pop(context),
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.grip),
              title: Text(t.translate('categories')),
              onTap: () => {
                Navigator.popAndPushNamed(context, categoryListRoute),
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.solidAddressBook),
              title: Text(t.translate('household_members')),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.stars_rounded),
              title: Text(t.translate('premium')),
              onTap: () {},
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.gear),
              title: Text(t.translate('settings')),
              onTap: () => Navigator.pushNamed(context, settingsRoute),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 22.0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: t.translate('home')),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: t.translate('bookings')),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.buildingColumns), label: t.translate('accounts')),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: t.translate('budgets')),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.bullseye), label: t.translate('goals')),
        ],
        currentIndex: _selectedPageIndex,
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
      body: _pages[_selectedPageIndex],
      floatingActionButton: OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        transitionType: ContainerTransitionType.fade,
        openBuilder: (context, _) => CreateBookingPage(),
        closedElevation: 6,
        closedShape: const CircleBorder(),
        closedColor: Colors.cyanAccent,
        closedBuilder: (context, openContainer) {
          return FloatingActionButton(
            onPressed: openContainer,
            backgroundColor: Colors.cyanAccent,
            child: const Icon(
              Icons.add_rounded,
              color: Colors.black87,
              size: 26.0,
            ),
          );
        },
      ),
    );
  }
}
