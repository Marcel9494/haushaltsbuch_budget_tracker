import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/account/account_bloc.dart';
import '../../../blocs/booking/booking_bloc.dart';
import '../../../blocs/category/category_bloc.dart';
import '../../../blocs/goal/goal_bloc.dart';
import '../../../data/enums/booking_selection_type.dart';
import '../../../data/models/booking.dart';
import '../../../features/bookings/presentation/pages/update_booking_page.dart';
import '../../../l10n/app_localizations.dart';

void showUpdateBookingBottomSheet(BuildContext parentContext, Booking booking, VoidCallback? onUpdateSuccess) {
  final t = AppLocalizations.of(parentContext);
  showModalBottomSheet(
    context: parentContext,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (BuildContext sheetContext) {
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
                        t.translate('update_or_delete_booking'),
                        style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: BookingSelectionType.values.length,
                itemBuilder: (context, index) {
                  final bookingSelectionType = BookingSelectionType.values[index];
                  return ListTile(
                    title: Text(
                      t.translate(bookingSelectionType.name),
                      style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      t.translate(bookingSelectionType.updateDescription()),
                      style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded, size: 24.0),
                    onTap: () {
                      Navigator.pop(parentContext);
                      Navigator.of(parentContext).push(
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(value: parentContext.read<BookingBloc>()),
                              BlocProvider.value(value: parentContext.read<CategoryBloc>()),
                              BlocProvider.value(value: parentContext.read<AccountBloc>()),
                              BlocProvider.value(value: parentContext.read<GoalBloc>()),
                            ],
                            child: UpdateBookingPage(
                              booking: booking,
                              bookingSelectionType: bookingSelectionType,
                              onSuccess: onUpdateSuccess,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
              ),
            ],
          ),
        ),
      );
    },
  );
}
