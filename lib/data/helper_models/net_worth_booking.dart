import '../../core/utils/date_helper.dart';
import '../enums/booking_type.dart';

// Schlanke Sicht auf eine Buchung mit nur den Feldern, die für die
// Vermögensentwicklung benötigt werden.
class NetWorthBooking {
  final BookingType bookingType;
  final double amount;
  final DateTime bookingDate;
  final String? debitAccountId;
  final String? targetAccountId;
  final bool isBooked;

  // Saldoanpassungen (beim Bearbeiten eines Kontostands) haben kein Konto zugeordnet,
  // haben den Kontostand aber trotzdem verändert.
  final bool isBalanceAdjustment;

  const NetWorthBooking({
    required this.bookingType,
    required this.amount,
    required this.bookingDate,
    this.debitAccountId,
    this.targetAccountId,
    this.isBooked = true,
    this.isBalanceAdjustment = false,
  });

  factory NetWorthBooking.fromMap(Map<String, dynamic> map, {Set<String> balanceAdjustmentTitles = const {}}) {
    final String? debitAccountId = map['debit_account_id'];
    final String? targetAccountId = map['target_account_id'];
    final BookingType bookingType = BookingType.fromString(map['booking_type']);
    return NetWorthBooking(
      bookingType: bookingType,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      bookingDate: parseDateOnly(map['booking_date']),
      debitAccountId: debitAccountId,
      targetAccountId: targetAccountId,
      isBooked: map['is_booked'] == true,
      isBalanceAdjustment: bookingType != BookingType.transfer &&
          debitAccountId == null &&
          targetAccountId == null &&
          map['category_id'] == null &&
          balanceAdjustmentTitles.contains(map['title']),
    );
  }
}
