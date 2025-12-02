import '../../features/bookings/data/enums/amount_type.dart';
import '../../features/bookings/data/enums/booking_type.dart';
import '../../features/bookings/data/enums/repetition_type.dart';

class Booking {
  final String? id;
  final String? uid;
  final DateTime? createdAt;
  final BookingType bookingType;
  final String title;
  final double amount;
  final AmountType amountType;
  final DateTime bookingDate;
  final RepetitionType repetitionType;
  final String? repetitionId;
  final String category;
  final String debitAccount;
  final String? targetAccount;
  final String goal;
  final String person;
  final bool isBooked;

  Booking({
    this.id,
    this.uid,
    this.createdAt,
    required this.bookingType,
    required this.title,
    required this.amount,
    required this.amountType,
    required this.bookingDate,
    required this.repetitionType,
    this.repetitionId,
    required this.category,
    required this.debitAccount,
    required this.targetAccount,
    required this.goal,
    required this.person,
    required this.isBooked,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      uid: map['uid'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      bookingType: BookingType.fromString(map['booking_type']),
      title: map['title'],
      amount: map['amount'],
      amountType: AmountType.fromString(map['amount_type']),
      bookingDate: DateTime.parse(map['booking_date']),
      repetitionType: RepetitionType.fromString(map['repetition_type']),
      repetitionId: map['repetition_id'],
      category: map['category'],
      debitAccount: map['debit_account'],
      targetAccount: map['target_account'],
      goal: map['goal'],
      person: map['person'],
      isBooked: map['is_booked'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'booking_type': bookingType.name,
      'title': title,
      'amount': amount,
      'amount_type': amountType.name,
      'booking_date': bookingDate.toIso8601String(),
      'repetition_type': repetitionType.name,
      'repetition_id': repetitionId,
      'category': category,
      'debit_account': debitAccount,
      'target_account': targetAccount,
      'goal': goal,
      'person': person,
      'is_booked': isBooked,
    };
  }
}
