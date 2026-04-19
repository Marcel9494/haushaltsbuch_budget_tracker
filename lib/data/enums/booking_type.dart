import 'package:flutter/material.dart';

enum BookingType {
  expense,
  income,
  transfer;

  static BookingType fromString(String s) => switch (s) {
        'expense' => BookingType.expense,
        'income' => BookingType.income,
        'transfer' => BookingType.transfer,
        _ => BookingType.expense,
      };
}

extension BookingTypeExtension on BookingType {
  String get name {
    switch (this) {
      case BookingType.expense:
        return 'expense';
      case BookingType.income:
        return 'income';
      case BookingType.transfer:
        return 'transfer';
    }
  }

  Color get color {
    switch (this) {
      case BookingType.expense:
        return Colors.redAccent;
      case BookingType.income:
        return Colors.green;
      case BookingType.transfer:
        return Colors.cyanAccent;
    }
  }
}
