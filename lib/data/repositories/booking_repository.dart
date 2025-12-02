import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/bookings/data/enums/booking_type.dart';
import '../models/booking.dart';

class BookingRepository {
  Future<Booking> createBooking(Booking newBooking) async {
    final createdBooking = await Supabase.instance.client.from('bookings').insert(newBooking.toMap()).select().single();
    return Booking.fromMap(createdBooking);
  }

  Future<List<Booking>> loadMonthlyBookings(DateTime selectedDate, String userId) async {
    final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    final monthlyBookings = await Supabase.instance.client
        .from('bookings')
        .select()
        .gte('booking_date', startOfMonth)
        .lt('booking_date', endOfMonth)
        .order('booking_date', ascending: false);
    return (monthlyBookings as List).map((data) => Booking.fromMap(data)).toList();
  }

  double calculateMonthlyRevenue(List<Booking> bookings) {
    double totalRevenue = 0;
    for (Booking booking in bookings) {
      if (booking.bookingType == BookingType.income) {
        totalRevenue += booking.amount;
      }
    }
    return totalRevenue;
  }

  double calculateDailyRevenue(List<Booking> bookings, DateTime day) {
    double totalRevenue = 0;
    for (Booking booking in bookings) {
      if (booking.bookingType == BookingType.income &&
          booking.bookingDate.year == day.year &&
          booking.bookingDate.month == day.month &&
          booking.bookingDate.day == day.day) {
        totalRevenue += booking.amount;
      }
    }
    return totalRevenue;
  }

  double calculateMonthlyExpenses(List<Booking> bookings) {
    double totalExpenses = 0;
    for (Booking booking in bookings) {
      if (booking.bookingType == BookingType.expense) {
        totalExpenses += booking.amount;
      }
    }
    return totalExpenses;
  }

  double calculateDailyExpenses(List<Booking> bookings, DateTime day) {
    double totalExpenses = 0;
    for (Booking booking in bookings) {
      if (booking.bookingType == BookingType.expense &&
          booking.bookingDate.year == day.year &&
          booking.bookingDate.month == day.month &&
          booking.bookingDate.day == day.day) {
        totalExpenses += booking.amount;
      }
    }
    return totalExpenses;
  }
}
