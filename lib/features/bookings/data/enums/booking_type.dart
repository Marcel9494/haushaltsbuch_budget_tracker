import 'package:flutter/material.dart';

enum BookingType {
  expense,
  income,
  transfer;

  static BookingType fromString(String s) => switch (s) {
        'Ausgabe' => BookingType.expense,
        'Einnahme' => BookingType.income,
        'Übertrag' => BookingType.transfer,
        _ => BookingType.expense,
      };
}

extension BookingTypeExtension on BookingType {
  String get name {
    switch (this) {
      case BookingType.expense:
        return 'Ausgabe';
      case BookingType.income:
        return 'Einnahme';
      case BookingType.transfer:
        return 'Übertrag';
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
