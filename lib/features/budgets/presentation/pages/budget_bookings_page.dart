import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/bottom_sheets/delete_budget_bottom_sheet.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/budget_repository.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/cards/booking_card.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../blocs/budget/budget_bloc.dart';
import '../../../../core/utils/bottom_sheets/update_budget_bottom_sheet.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/models/budget.dart';

class BudgetBookingsPage extends StatefulWidget {
  final Budget budget;
  final List<Booking> bookings;

  const BudgetBookingsPage({
    super.key,
    required this.budget,
    required this.bookings,
  });

  @override
  State<BudgetBookingsPage> createState() => _BudgetBookingsPageState();
}

class _BudgetBookingsPageState extends State<BudgetBookingsPage> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      create: (context) => BudgetBloc(BudgetRepository()),
      child: Builder(builder: (innerContext) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${widget.budget.category!.categoryName} ${t.translate('budgets')}'),
            actions: [
              IconButton(
                icon: Icon(Icons.edit_rounded),
                onPressed: () {
                  showUpdateBudgetBottomSheet(context, widget.budget);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete_forever_rounded),
                onPressed: () {
                  final budgetBloc = innerContext.read<BudgetBloc>();
                  showDeleteBudgetBottomSheet(innerContext, widget.budget, budgetBloc);
                },
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: widget.bookings.length,
            itemBuilder: (context, index) {
              return BookingCard(
                booking: widget.bookings[index],
              );
            },
          ),
        );
      }),
    );
  }
}
