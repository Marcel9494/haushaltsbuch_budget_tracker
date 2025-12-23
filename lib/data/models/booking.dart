import '../../features/bookings/data/enums/amount_type.dart';
import '../../features/bookings/data/enums/booking_type.dart';
import '../../features/bookings/data/enums/repetition_type.dart';
import 'account.dart';
import 'category.dart';

class Booking {
  final String? id;
  final String? userId;
  final DateTime? createdAt;
  final BookingType bookingType;
  final String title;
  final double amount;
  final AmountType amountType;
  final DateTime bookingDate;
  final RepetitionType repetitionType;
  final String? repetitionId;
  final String? categoryId;
  final Category? category;
  final String debitAccountId;
  final Account? debitAccount;
  final String? targetAccountId;
  final Account? targetAccount;
  final String goal;
  final String person;
  final bool isBooked;

  Booking({
    this.id,
    this.userId,
    this.createdAt,
    required this.bookingType,
    required this.title,
    required this.amount,
    required this.amountType,
    required this.bookingDate,
    required this.repetitionType,
    this.repetitionId,
    this.category,
    this.categoryId,
    this.debitAccount,
    required this.debitAccountId,
    this.targetAccount,
    required this.targetAccountId,
    required this.goal,
    required this.person,
    required this.isBooked,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['user_id'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      bookingType: BookingType.fromString(map['booking_type']),
      title: map['title'],
      amount: map['amount'],
      amountType: AmountType.fromString(map['amount_type']),
      bookingDate: DateTime.parse(map['booking_date']),
      repetitionType: RepetitionType.fromString(map['repetition_type']),
      repetitionId: map['repetition_id'],
      categoryId: map['category_id'],
      category: map['categories'] != null ? Category.fromMap(map['categories']) : null,
      debitAccount: map['debit_account'] != null ? Account.fromMap(map['debit_account']) : null,
      debitAccountId: map['debit_account_id'],
      targetAccount: map['target_account'] != null ? Account.fromMap(map['target_account']) : null,
      targetAccountId: map['target_account_id'],
      goal: map['goal'],
      person: map['person'],
      isBooked: map['is_booked'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'booking_type': bookingType.name,
      'title': title,
      'amount': amount,
      'amount_type': amountType.name,
      'booking_date': bookingDate.toIso8601String(),
      'repetition_type': repetitionType.name,
      'repetition_id': repetitionId,
      'category_id': categoryId,
      'debit_account_id': debitAccountId,
      'target_account_id': targetAccountId,
      'goal': goal,
      'person': person,
      'is_booked': isBooked,
    };
  }
}
