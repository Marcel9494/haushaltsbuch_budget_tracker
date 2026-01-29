import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/features/auth/presentation/pages/register_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../blocs/account/account_bloc.dart';
import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../blocs/budget/budget_bloc.dart';
import '../../../../blocs/category/category_bloc.dart';
import '../../../../blocs/goal/goal_bloc.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/repositories/budget_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/goal_repository.dart';
import '../../../home/presentation/pages/home_page.dart';

class AuthenticationGatePage extends StatelessWidget {
  const AuthenticationGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => BookingBloc(BookingRepository())),
          BlocProvider(create: (_) => CategoryBloc(CategoryRepository())),
          BlocProvider(create: (_) => AccountBloc(AccountRepository())),
          BlocProvider(create: (_) => BudgetBloc(BudgetRepository())),
          BlocProvider(create: (_) => GoalBloc(GoalRepository())),
        ],
        child: const HomePage(currentPageIndex: 0),
      );
    }

    return const RegisterPage();
  }
}
