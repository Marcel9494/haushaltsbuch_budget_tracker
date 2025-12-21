import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:haushaltsbuch_budget_tracker/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'blocs/booking/booking_bloc.dart';
import 'core/consts/route_consts.dart';
import 'data/repositories/booking_repository.dart';
import 'features/accounts/presentation/pages/create_account_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/bookings/presentation/pages/create_booking_page.dart';
import 'features/categories/presentation/pages/category_list_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
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
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final event = data.event;

    print(event);
    if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => BookingBloc(BookingRepository()),
            child: HomePage(),
          ),
        ),
      );
    } else if (event == AuthChangeEvent.passwordRecovery) {
      // Benutzer wurde über Passwort-Reset-Link reingebracht
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haushaltsbuch - Budget Tracker',
      debugShowCheckedModeBanner: false,
      locale: const Locale('de', 'DE'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
      home: const RegisterPage(),
      routes: {
        forgotPasswordRoute: (context) => const ForgotPasswordPage(),
        createBookingRoute: (context) => const CreateBookingPage(),
        createAccountRoute: (context) => const CreateAccountPage(),
        categoryListRoute: (context) => const CategoryListPage(),
        settingsRoute: (context) => const SettingsPage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case registerRoute:
            return PageTransition(
              type: PageTransitionType.fade,
              settings: settings,
              child: RegisterPage(),
            );
          case loginRoute:
            return PageTransition(
              type: PageTransitionType.fade,
              settings: settings,
              child: LoginPage(),
            );
          case homeRoute:
            return PageTransition(
              type: PageTransitionType.fade,
              settings: settings,
              child: BlocProvider(
                create: (context) => BookingBloc(BookingRepository()),
                child: HomePage(),
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}
