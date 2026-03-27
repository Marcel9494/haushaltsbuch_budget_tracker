import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/blocs/category/category_event.dart';
import 'package:haushaltsbuch_budget_tracker/blocs/dashboard_element/dashboard_element_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/blocs/dashboard_element/dashboard_element_event.dart';
import 'package:haushaltsbuch_budget_tracker/core/consts/route_consts.dart';
import 'package:haushaltsbuch_budget_tracker/core/page_arguments/category_list_page_arguments.dart';
import 'package:haushaltsbuch_budget_tracker/features/budgets/presentation/pages/budget_list_page.dart';
import 'package:haushaltsbuch_budget_tracker/features/categories/data/enums/category_type.dart';
import 'package:haushaltsbuch_budget_tracker/features/goals/presentation/pages/goal_list_page.dart';

import '../../../../blocs/account/account_bloc.dart';
import '../../../../blocs/account/account_event.dart';
import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../blocs/budget/budget_bloc.dart';
import '../../../../blocs/budget/budget_event.dart';
import '../../../../blocs/category/category_bloc.dart';
import '../../../../blocs/goal/goal_bloc.dart';
import '../../../../blocs/goal/goal_event.dart';
import '../../../../data/enums/period_of_time_type.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/budget_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../accounts/presentation/pages/account_list_page.dart';
import '../../../bookings/presentation/pages/booking_list_page.dart';
import '../../../bookings/presentation/pages/create_booking_page.dart';
import '../widgets/navigation/month_picker_bar.dart';
import 'home_content_page.dart';

class HomePage extends StatefulWidget {
  final int currentPageIndex;

  const HomePage({
    super.key,
    this.currentPageIndex = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late BookingBloc _bookingBloc;
  late DashboardElementBloc _dashboardElementBloc;
  late CategoryBloc _categoryBloc;
  late AccountBloc _accountBloc;
  late BudgetBloc _budgetBloc;
  late GoalBloc _goalBloc;
  bool _showUpcomingBookings = false;
  DateTime _currentSelectedDate = DateTime.now();
  PeriodOfTimeType _currentPeriodOfTime = PeriodOfTimeType.monthly;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();

    _selectedPageIndex = widget.currentPageIndex;

    _bookingBloc = context.read<BookingBloc>();
    _dashboardElementBloc = context.read<DashboardElementBloc>();
    _categoryBloc = context.read<CategoryBloc>();
    _accountBloc = context.read<AccountBloc>();
    _budgetBloc = context.read<BudgetBloc>();
    _goalBloc = context.read<GoalBloc>();

    onPeriodOfTimeChanged(_currentPeriodOfTime);
    _loadDashboardElements();
    _loadCategories();
    _loadAccounts();
    _loadMonthlyBudgets(_currentSelectedDate);
    _loadGoals();
  }

  void _loadDashboardElements() {
    _dashboardElementBloc.add(LoadUserDashboardElements());
  }

  void _loadMonthlyBookings(DateTime selectedDate) {
    _bookingBloc.add(
      LoadMonthlyBookings(selectedDate: selectedDate),
    );
  }

  void _loadYearlyBookings(int selectedYear) {
    _bookingBloc.add(
      LoadYearlyBookings(selectedYear: selectedYear),
    );
  }

  void onPeriodOfTimeChanged(PeriodOfTimeType newPeriodOfTime) {
    setState(() {
      _currentPeriodOfTime = newPeriodOfTime;
      if (_currentPeriodOfTime == PeriodOfTimeType.monthly) {
        _loadMonthlyBookings(_currentSelectedDate);
        _loadMonthlyBudgets(_currentSelectedDate);
      } else {
        _loadYearlyBookings(_currentSelectedDate.year);
        _loadYearlyBudgets(_currentSelectedDate.year);
      }
    });
  }

  void onShowUpcomingBookingsChanged(bool showUpcomingBookings) {
    setState(() {
      _showUpcomingBookings = showUpcomingBookings;
    });
  }

  void _loadCategories() {
    _categoryBloc.add(LoadCategories());
  }

  void _loadAccounts() {
    _accountBloc.add(LoadAccounts());
  }

  void _loadMonthlyBudgets(DateTime selectedDate) {
    _budgetBloc.add(LoadMonthlyBudgets(selectedDate));
  }

  void _loadYearlyBudgets(int selectedYear) {
    _budgetBloc.add(LoadYearlyBudgets(selectedYear));
  }

  void _loadGoals() {
    _goalBloc.add(LoadGoals());
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
          showUpcomingBookings: _showUpcomingBookings,
          onShowUpcomingBookingsChanged: (showUpcomingBookings) {
            onShowUpcomingBookingsChanged(showUpcomingBookings);
          },
          currentPeriodOfTimeType: _currentPeriodOfTime,
          onPeriodOfTimeChanged: (newPeriodOfTime) {
            onPeriodOfTimeChanged(newPeriodOfTime);
          },
        ),
        BlocProvider(
          create: (context) => AccountBloc(AccountRepository()),
          child: AccountListPage(),
        ),
        BlocProvider(
          create: (context) => BudgetBloc(BudgetRepository()),
          child: BudgetListPage(
            key: ValueKey(_currentSelectedDate),
            currentSelectedDate: _currentSelectedDate,
            currentPeriodOfTimeType: _currentPeriodOfTime,
            onPeriodOfTimeChanged: (newPeriodOfTime) {
              onPeriodOfTimeChanged(newPeriodOfTime);
            },
          ),
        ),
        GoalListPage(),
      ];
  final List<String> _pageTitle = [
    'dashboard',
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
              leading: Icon(Icons.dashboard_rounded, color: _selectedPageIndex == 0 ? Colors.cyanAccent : Colors.white),
              title: Text(t.translate('dashboard'), style: TextStyle(color: _selectedPageIndex == 0 ? Colors.cyanAccent : Colors.white)),
              onTap: () => {
                _onItemTapped(0),
                Navigator.pop(context),
              },
            ),
            ListTile(
              leading: Icon(Icons.menu_book_rounded, color: _selectedPageIndex == 1 ? Colors.cyanAccent : Colors.white),
              title: Text(t.translate('bookings'), style: TextStyle(color: _selectedPageIndex == 1 ? Colors.cyanAccent : Colors.white)),
              onTap: () => {
                _onItemTapped(1),
                Navigator.pop(context),
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.buildingColumns, size: 22.0, color: _selectedPageIndex == 2 ? Colors.cyanAccent : Colors.white),
              title: Text(t.translate('accounts'), style: TextStyle(color: _selectedPageIndex == 2 ? Colors.cyanAccent : Colors.white)),
              onTap: () => {
                _onItemTapped(2),
                Navigator.pop(context),
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet_rounded, color: _selectedPageIndex == 3 ? Colors.cyanAccent : Colors.white),
              title: Text(t.translate('budgets'), style: TextStyle(color: _selectedPageIndex == 3 ? Colors.cyanAccent : Colors.white)),
              onTap: () => {
                _onItemTapped(3),
                Navigator.pop(context),
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.bullseye, color: _selectedPageIndex == 4 ? Colors.cyanAccent : Colors.white),
              title: Text(t.translate('goals'), style: TextStyle(color: _selectedPageIndex == 4 ? Colors.cyanAccent : Colors.white)),
              onTap: () => {
                _onItemTapped(4),
                Navigator.pop(context),
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.grip, color: Colors.white),
              title: Text(t.translate('categories'), style: TextStyle(color: Colors.white)),
              onTap: () => {
                Navigator.popAndPushNamed(
                  context,
                  categoryListRoute,
                  arguments: CategoryListPageArguments(CategoryType.expenses),
                ),
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.solidAddressBook, color: Colors.white),
              title: Text(t.translate('household_members'), style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.stars_rounded, color: Colors.white),
              title: Text(t.translate('premium'), style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.gear, color: Colors.white),
              title: Text(t.translate('settings'), style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.popAndPushNamed(context, settingsRoute),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _selectedPageIndex == 2 || _selectedPageIndex == 4
              ? SizedBox.shrink()
              : Column(
                  children: [
                    Divider(height: 0.5),
                    MonthPickerBar(
                      initialDate: _currentSelectedDate,
                      onDateChanged: (newDate) {
                        setState(() {
                          _currentSelectedDate = newDate;
                          _loadMonthlyBookings(_currentSelectedDate);
                          _loadMonthlyBudgets(_currentSelectedDate);
                        });
                      },
                      onPeriodOfTimeChanged: (isYear) {
                        if (isYear) {
                          _currentSelectedDate = DateTime(_currentSelectedDate.year, 1, 1);
                          onPeriodOfTimeChanged(PeriodOfTimeType.yearly);
                        } else {
                          onPeriodOfTimeChanged(PeriodOfTimeType.monthly);
                        }
                      },
                    ),
                  ],
                ),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            iconSize: 22.0,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: t.translate('dashboard')),
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
        ],
      ),
      body: _pages[_selectedPageIndex],
      floatingActionButton: OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        transitionType: ContainerTransitionType.fade,
        openBuilder: (context, _) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _categoryBloc),
              BlocProvider.value(value: _accountBloc),
              BlocProvider.value(value: _goalBloc),
            ],
            child: CreateBookingPage(),
          );
        },
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
    );
  }
}
