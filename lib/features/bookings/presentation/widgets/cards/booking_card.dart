import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/data/enums/booking_type.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../data/models/booking.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
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
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.bookingType == BookingType.transfer ? t.translate('transfer') : booking.category!.categoryName,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        booking.goal,
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
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.title, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Text(
                            booking.debitAccount,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey),
                          ),
                          booking.targetAccount != null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                  child: FaIcon(FontAwesomeIcons.anglesRight, size: 14, color: Colors.grey),
                                )
                              : SizedBox.shrink(),
                          booking.targetAccount != null
                              ? Text(
                                  booking.targetAccount!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // TODO Repetition icon integrieren
                            /* Icon(
                              booking.repetitionType != RepetitionType.none ? Icons.repeat_rounded : null,
                              color: Colors.white,
                              size: 16.0,
                            ),*/
                            Text(
                              formatCurrency(booking.amount, 'EUR'),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: booking.bookingType.color),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          booking.person,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
