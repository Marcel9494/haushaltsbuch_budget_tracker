import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:haushaltsbuch_budget_tracker/blocs/on_boarding/on_boarding_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/category_repository.dart';
import 'package:haushaltsbuch_budget_tracker/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:haushaltsbuch_budget_tracker/features/budgets/presentation/pages/budget_bookings_page.dart';
import 'package:haushaltsbuch_budget_tracker/features/onboarding/presentation/pages/category_onboarding_page.dart';
import 'package:haushaltsbuch_budget_tracker/features/settings/presentation/pages/change_email_page.dart';
import 'package:haushaltsbuch_budget_tracker/features/settings/presentation/pages/upgrade_account_page.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'blocs/account/account_bloc.dart';
import 'blocs/booking/booking_bloc.dart';
import 'blocs/budget/budget_bloc.dart';
import 'blocs/category/category_bloc.dart';
import 'blocs/dashboard_element/dashboard_element_bloc.dart';
import 'blocs/goal/goal_bloc.dart';
import 'blocs/onboarding_account/onboarding_account_bloc.dart';
import 'blocs/onboarding_category/onboarding_category_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/user/user_event.dart';
import 'core/consts/route_consts.dart';
import 'core/page_arguments/budget_bookings_page_arguments.dart';
import 'core/page_arguments/category_bookings_page_arguments.dart';
import 'core/page_arguments/category_list_page_arguments.dart';
import 'core/page_arguments/goal_bookings_page_arguments.dart';
import 'core/page_arguments/home_page_arguments.dart';
import 'core/page_arguments/update_account_page_arguments.dart';
import 'core/page_arguments/update_booking_page_arguments.dart';
import 'core/page_arguments/update_budget_page_arguments.dart';
import 'core/page_arguments/update_category_page_arguments.dart';
import 'core/page_arguments/update_goal_page_arguments.dart';
import 'core/utils/app_flushbar.dart';
import 'core/utils/currency_helper.dart';
import 'data/models/user.dart';
import 'data/repositories/account_repository.dart';
import 'data/repositories/booking_repository.dart';
import 'data/repositories/budget_repository.dart';
import 'data/repositories/dashboard_element_repository.dart';
import 'data/repositories/goal_repository.dart';
import 'data/repositories/onboarding_account_repository.dart';
import 'data/repositories/onboarding_category_repository.dart';
import 'data/repositories/user_repository.dart';
import 'features/accounts/presentation/pages/account_list_page.dart';
import 'features/accounts/presentation/pages/create_account_page.dart';
import 'features/accounts/presentation/pages/update_account_page.dart';
import 'features/auth/presentation/pages/authentication_gate_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/bookings/presentation/pages/create_booking_page.dart';
import 'features/bookings/presentation/pages/update_booking_page.dart';
import 'features/budgets/presentation/pages/create_budget_page.dart';
import 'features/budgets/presentation/pages/update_budget_page.dart';
import 'features/categories/presentation/pages/category_bookings_page.dart';
import 'features/categories/presentation/pages/category_list_page.dart';
import 'features/categories/presentation/pages/update_category_page.dart';
import 'features/dashboard/presentation/pages/update_dashboard_page.dart';
import 'features/goals/presentation/pages/completed_goal_list_page.dart';
import 'features/goals/presentation/pages/create_goal_page.dart';
import 'features/goals/presentation/pages/goal_bookings_page.dart';
import 'features/goals/presentation/pages/goal_list_page.dart';
import 'features/goals/presentation/pages/update_goal_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/onboarding/presentation/pages/account_onboarding_page.dart';
import 'features/onboarding/presentation/pages/completed_onboarding_page.dart';
import 'features/onboarding/presentation/pages/dashboard_onboarding_page.dart';
import 'features/settings/presentation/pages/above_page.dart';
import 'features/settings/presentation/pages/change_password_page.dart';
import 'features/settings/presentation/pages/imprint_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final userBloc = UserBloc(UserRepository());

void main() async {
  Locale? initialLocale;

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_KEY');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
    ),
  );

  Supabase.instance.client.auth.onAuthStateChange.listen(
    (data) async {
      final event = data.event;

      if (event == AuthChangeEvent.initialSession) {
        UserRepository userRepository = UserRepository();
        if (Supabase.instance.client.auth.currentUser != null) {
          User user = await userRepository.loadUser(Supabase.instance.client.auth.currentUser!.id);
          CurrencyHelper.instance.setCurrency(user.currencyCode);

          final timezone = await FlutterTimezone.getLocalTimezone();
          await userRepository.updateUserTimezone(user.id!, timezone.identifier);

          initialLocale = user.locale;
          final context = navigatorKey.currentContext;
          if (context != null) {
            MyApp.of(context)?.setLocale(user.locale);
          }
        }
      } else if (event == AuthChangeEvent.signedIn) {
        UserRepository userRepository = UserRepository();
        bool userExists = await userRepository.existsUser(Supabase.instance.client.auth.currentUser!.id);

        if (userExists == false) {
          final locale = PlatformDispatcher.instance.locale;
          final localeString = locale.countryCode != null ? locale.toString() : '${locale.languageCode}_US';
          final timezone = await FlutterTimezone.getLocalTimezone();

          final newUser = User(
            id: Supabase.instance.client.auth.currentUser!.id,
            locale: locale,
            timezone: timezone.identifier,
            currencyCode: NumberFormat.simpleCurrency(locale: localeString).currencyName ?? '',
            hasOnboardingCompleted: false,
          );

          userBloc.add(CreateUser(user: newUser));
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const CategoryOnboardingPage(),
            ),
            (route) => false,
          );
        } else {
          User user = await userRepository.loadUser(Supabase.instance.client.auth.currentUser!.id);
          CurrencyHelper.instance.setCurrency(user.currencyCode);

          final timezone = await FlutterTimezone.getLocalTimezone();
          await userRepository.updateUserTimezone(user.id!, timezone.identifier);

          initialLocale = user.locale;
          final context = navigatorKey.currentContext;
          if (context != null) {
            MyApp.of(context)?.setLocale(user.locale);
          }
          if (user.hasOnboardingCompleted) {
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: userBloc),
                    BlocProvider(create: (context) => BookingBloc(BookingRepository(), AccountRepository())),
                    BlocProvider(create: (context) => DashboardElementBloc(DashboardElementRepository())),
                    BlocProvider(create: (context) => CategoryBloc(CategoryRepository())),
                    BlocProvider(create: (context) => AccountBloc(AccountRepository())),
                    BlocProvider(create: (context) => BudgetBloc(BudgetRepository())),
                    BlocProvider(create: (context) => GoalBloc(GoalRepository())),
                  ],
                  child: HomePage(currentPageIndex: 0),
                ),
              ),
              (route) => false,
            );
          } else {
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const CategoryOnboardingPage(),
              ),
              (route) => false,
            );
          }
        }
      } else if (event == AuthChangeEvent.userUpdated) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => BookingBloc(BookingRepository(), AccountRepository())),
                BlocProvider(create: (context) => DashboardElementBloc(DashboardElementRepository())),
                BlocProvider(create: (context) => CategoryBloc(CategoryRepository())),
                BlocProvider(create: (context) => AccountBloc(AccountRepository())),
                BlocProvider(create: (context) => BudgetBloc(BudgetRepository())),
                BlocProvider(create: (context) => GoalBloc(GoalRepository())),
              ],
              child: HomePage(currentPageIndex: 0),
            ),
          ),
          (route) => false,
        );
      } else if (event == AuthChangeEvent.passwordRecovery) {
        // Benutzer wurde über Passwort-Reset-Link reingebracht
        navigatorKey.currentState!.push(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
        );
      } else if (event == AuthChangeEvent.signedOut) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RegisterPage()),
          (route) => false,
        );
      }
    },
    onError: (error) async {
      final context = navigatorKey.currentContext;
      if (context == null) {
        return;
      }
      final t = AppLocalizations.of(context);
      if (error is AuthException && error.statusCode == 'identity_already_exists') {
        AppFlushbar.show(
          context,
          message: t.translate('google_identity_already_exists_error'),
          duration: const Duration(seconds: 7),
        );
      } else if (error is AuthException && error.statusCode == 'otp_expired') {
        // Benutzer hat beide Bestätigungslink für die E-Mail Änderung geklickt. Beim zweiten
        // Link ist der Token abgelaufen, daher wird hier otp_expired geworfen.
        // Die E-Mail Änderung ist aber trotzdem erfolgreich.
        await Supabase.instance.client.auth.refreshSession();
        AppFlushbar.show(
          context,
          icon: Icons.check_circle_rounded,
          iconColor: Colors.greenAccent,
          message: t.translate('email_change_successful'),
        );
      } else {
        AppFlushbar.show(
          context,
          message: t.translate('upgrade_account_error'),
        );
      }
    },
  );

  runApp(MyApp(initialLocale: initialLocale));
}

class MyApp extends StatefulWidget {
  final Locale? initialLocale;

  const MyApp({
    super.key,
    required this.initialLocale,
  });

  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Wenn _locale null ist, verwendet MaterialApp die Systemsprache des Geräts
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = Locale(locale.toString().split('_').first);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => OnboardingCategoryBloc(OnboardingCategoryRepository())),
        BlocProvider(create: (context) => OnboardingAccountBloc(OnboardingAccountRepository())),
      ],
      child: MaterialApp(
        title: 'Haushaltsbuch - Budget Tracker',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark().copyWith(
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.cyanAccent,
            selectionColor: Color(0x5526C6DA),
            selectionHandleColor: Colors.cyanAccent,
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: WidgetStateTextStyle.resolveWith(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.error)) {
                  return const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500);
                }
                if (states.contains(WidgetState.focused)) {
                  return const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w500);
                }
                return const TextStyle(color: Colors.grey); // Standard
              },
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade700),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent, width: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.cyanAccent,
            ),
          ),
          datePickerTheme: DatePickerThemeData(
            todayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.black87;
              }
              return Colors.white70;
            }),
            todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.cyanAccent;
              }
              return null;
            }),
            dayOverlayColor: WidgetStateProperty.all(Colors.cyanAccent.withAlpha(100)),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.cyanAccent;
              }
              return null;
            }),
            yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.cyanAccent;
              }
              return null;
            }),
            cancelButtonStyle: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(Colors.grey),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.cyanAccent,
              side: BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.cyanAccent,
            ),
          ),
          tabBarTheme: TabBarThemeData(
            labelColor: Colors.cyanAccent,
            unselectedLabelColor: Colors.white,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(
                color: Colors.cyanAccent,
                width: 3.0,
              ),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        themeMode: ThemeMode.system,
        navigatorKey: navigatorKey,
        home: const AuthenticationGatePage(),
        routes: {
          forgotPasswordRoute: (context) => const ForgotPasswordPage(),
          createBookingRoute: (context) => const CreateBookingPage(),
          createAccountRoute: (context) => const CreateAccountPage(),
          createBudgetRoute: (context) => const CreateBudgetPage(),
          createGoalRoute: (context) => const CreateGoalPage(),
          accountListRoute: (context) => const AccountListPage(),
          goalListRoute: (context) => const GoalListPage(),
          completedGoalListRoute: (context) => const CompletedGoalListPage(),
          settingsRoute: (context) => const SettingsPage(),
          changeEmailRoute: (context) => const ChangeEmailPage(),
          changePasswordRoute: (context) => const ChangePasswordPage(),
          upgradeAccountRoute: (context) => const UpgradeAccountPage(),
          updateDashboardRoute: (context) => const UpdateDashboardPage(),
          categoryOnboardingRoute: (context) => const CategoryOnboardingPage(),
          dashboardOnboardingRoute: (context) => const DashboardOnboardingPage(),
          accountOnboardingRoute: (context) => const AccountOnboardingPage(),
          aboveRoute: (context) => const AbovePage(),
          imprintRoute: (context) => const ImprintPage(),
          completedOnboardingRoute: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => OnboardingBloc(
                      categoryRepository: CategoryRepository(),
                      accountRepository: AccountRepository(),
                      dashboardRepository: DashboardElementRepository(),
                      userRepository: UserRepository(),
                    ),
                  ),
                  BlocProvider(create: (context) => CategoryBloc(CategoryRepository())),
                  BlocProvider(create: (context) => AccountBloc(AccountRepository())),
                  BlocProvider(create: (context) => DashboardElementBloc(DashboardElementRepository())),
                ],
                child: const CompletedOnboardingPage(),
              ),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case registerRoute:
              return PageTransition(
                type: PageTransitionType.fade,
                settings: settings,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<UserBloc>.value(value: userBloc),
                  ],
                  child: RegisterPage(),
                ),
              );
            case loginRoute:
              return PageTransition(
                type: PageTransitionType.fade,
                settings: settings,
                child: LoginPage(),
              );
            case homeRoute:
              final args = settings.arguments as HomePageArguments;
              return PageTransition(
                type: PageTransitionType.fade,
                settings: settings,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (context) => BookingBloc(BookingRepository(), AccountRepository())),
                    BlocProvider(create: (context) => DashboardElementBloc(DashboardElementRepository())),
                    BlocProvider(create: (context) => CategoryBloc(CategoryRepository())),
                    BlocProvider(create: (context) => AccountBloc(AccountRepository())),
                    BlocProvider(create: (context) => BudgetBloc(BudgetRepository())),
                    BlocProvider(create: (context) => GoalBloc(GoalRepository())),
                  ],
                  child: HomePage(currentPageIndex: args.currentPageIndex),
                ),
              );
            case categoryListRoute:
              final args = settings.arguments as CategoryListPageArguments;
              return MaterialPageRoute<String>(
                builder: (context) => CategoryListPage(
                  categoryType: args.categoryType,
                ),
                settings: settings,
              );
            case budgetBookingsRoute:
              final args = settings.arguments as BudgetBookingsPageArguments;
              return MaterialPageRoute<String>(
                builder: (context) => BudgetBookingsPage(
                  budget: args.budget,
                  bookings: args.bookings,
                  currentSelectedDate: args.currentSelectedDate,
                  currentPeriodOfTimeType: args.currentPeriodOfTimeType,
                ),
                settings: settings,
              );
            case categoryBookingsRoute:
              final args = settings.arguments as CategoryBookingsPageArguments;
              return MaterialPageRoute<String>(
                builder: (context) => CategoryBookingsPage(
                  category: args.category,
                  bookingType: args.bookingType,
                  bookings: args.bookings,
                  currentSelectedDate: args.currentSelectedDate,
                  currentPeriodOfTimeType: args.currentPeriodOfTimeType,
                ),
                settings: settings,
              );
            case goalBookingsRoute:
              final args = settings.arguments as GoalBookingsPageArguments;
              return MaterialPageRoute<String>(
                builder: (context) => GoalBookingsPage(
                  goal: args.goal,
                  goalBookings: args.goalBookings,
                ),
                settings: settings,
              );
            case updateBookingRoute:
              final args = settings.arguments as UpdateBookingPageArguments;
              return MaterialPageRoute<String>(
                builder: (context) => UpdateBookingPage(
                  booking: args.booking,
                  bookingSelectionType: args.bookingSelectionType,
                  onSuccess: args.onSuccess,
                ),
                settings: settings,
              );
            case updateCategoryRoute:
              final args = settings.arguments as UpdateCategoryPageArguments;
              return MaterialPageRoute<String>(
                builder: (context) => UpdateCategoryPage(
                  category: args.category,
                ),
                settings: settings,
              );
            case updateAccountRoute:
              final args = settings.arguments as UpdateAccountPageArguments;
              return MaterialPageRoute<String>(
                builder: (context) => UpdateAccountPage(
                  account: args.account,
                ),
                settings: settings,
              );
            case updateBudgetRoute:
              final args = settings.arguments as UpdateBudgetPageArguments;
              return MaterialPageRoute<String>(
                builder: (context) => UpdateBudgetPage(
                  budget: args.budget,
                  budgetSelectionType: args.budgetSelectionType,
                ),
                settings: settings,
              );
            case updateGoalRoute:
              final args = settings.arguments as UpdateGoalPageArguments;
              return MaterialPageRoute<String>(
                builder: (context) => UpdateGoalPage(
                  goal: args.goal,
                ),
                settings: settings,
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
