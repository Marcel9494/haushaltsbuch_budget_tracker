import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/cards/booking_card.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../core/consts/route_consts.dart';
import '../../../../core/page_arguments/updateBudgetPageArguments.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/enums/budget_selection_type.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.budget.category!.categoryName} ${t.translate('budgets')}'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                builder: (context) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 14.0),
                                  child: Text(
                                    t.translate('update_budget'),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 28),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: BudgetSelectionType.values.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(
                                  BudgetSelectionType.values[index].name,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${BudgetSelectionType.values[index].updateDescription(widget.budget.category!.categoryName)} ${BudgetSelectionType.values[index] == BudgetSelectionType.single ? '(${formatMonthYear(context, widget.budget.budgetDate!)})' : ''}',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: const Icon(Icons.keyboard_arrow_right_rounded, size: 24.0),
                                onTap: () {
                                  Navigator.popAndPushNamed(
                                    context,
                                    updateBudgetRoute,
                                    arguments: UpdateBudgetPageArguments(widget.budget, BudgetSelectionType.values[index]),
                                  );
                                },
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_forever_rounded),
            onPressed: () {
              Navigator.of(context).pop();
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
  }
}
