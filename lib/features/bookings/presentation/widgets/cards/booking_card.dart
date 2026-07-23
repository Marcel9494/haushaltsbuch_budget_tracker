import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/bottom_sheets/update_booking_bottom_sheet.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/booking_type.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../../blocs/account/account_bloc.dart';
import '../../../../../blocs/booking/booking_bloc.dart';
import '../../../../../blocs/category/category_bloc.dart';
import '../../../../../blocs/goal/goal_bloc.dart';
import '../../../../../core/utils/currency_helper.dart';
import '../../../../../data/enums/booking_selection_type.dart';
import '../../../../../data/models/booking.dart';
import '../../pages/update_booking_page.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onUpdateSuccess;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onUpdateSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        if (booking.repetitionId == null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<BookingBloc>()),
                  BlocProvider.value(value: context.read<CategoryBloc>()),
                  BlocProvider.value(value: context.read<AccountBloc>()),
                  BlocProvider.value(value: context.read<GoalBloc>()),
                ],
                child: UpdateBookingPage(
                  booking: booking,
                  bookingSelectionType: BookingSelectionType.single,
                  onSuccess: onUpdateSuccess,
                ),
              ),
            ),
          );
        } else {
          showUpdateBookingBottomSheet(context, booking, onUpdateSuccess);
        }
      },
      child: Card(
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: booking.bookingType.color, width: 3.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 6.0, 0.0, 6.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.bookingType == BookingType.transfer
                              ? t.translate('transfer')
                              : booking.category == null
                                  ? t.translate('no_category')
                                  : booking.category!.categoryName,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          booking.goal == null ? '' : booking.goal!.goalName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 42,
                    width: 1.3,
                    color: Colors.white30,
                    margin: const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.title == '' ? t.translate('unknown') : booking.title, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4.0),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                booking.debitAccount != null ? booking.debitAccount!.name : t.translate('no_account'),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            booking.targetAccount != null
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                    child: FaIcon(FontAwesomeIcons.anglesRight, size: 14, color: Colors.grey),
                                  )
                                : SizedBox.shrink(),
                            booking.targetAccount != null
                                ? Expanded(
                                    child: Text(
                                      booking.targetAccount!.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyHelper.instance.formatCurrency(booking.amount, context),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: booking.bookingType.color),
                          ),
                          SizedBox(height: 4.0),
                          Text(''),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
