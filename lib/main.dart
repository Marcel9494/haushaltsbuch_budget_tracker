import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:haushaltsbuch_budget_tracker/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/consts/route_consts.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/home/presentation/pages/home_page.dart';
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
    final session = data.session;
    final event = data.event;

    if (event == AuthChangeEvent.signedIn && session != null) {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomePage(),
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
      locale: const Locale('de'),
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
      ),
      themeMode: ThemeMode.system,
      navigatorKey: navigatorKey,
      home: const RegisterPage(),
      routes: {
        forgotPasswordRoute: (context) => const ForgotPasswordPage(),
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
              child: HomePage(),
            );
          default:
            return null;
        }
      },
    );
  }
}
