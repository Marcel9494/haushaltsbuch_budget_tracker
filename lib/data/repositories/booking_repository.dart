import 'package:collection/collection.dart';
import 'package:haushaltsbuch_budget_tracker/data/helper_models/booking_category_stats.dart';
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

  List<BookingCategoryStats> calculateMonthlyBookingsByCategory(List<Booking> bookings, BookingType selectedBookingType) {
    final Map<String, double> categoryAmount = {};
    for (final booking in bookings) {
      if (booking.bookingType == selectedBookingType) {
        categoryAmount[booking.category] = (categoryAmount[booking.category] ?? 0) + booking.amount;
      }
    }

    final double totalAmount = categoryAmount.values.fold(0, (sum, value) => sum + value);
    final List<BookingCategoryStats> bookingCategoryStats = categoryAmount.entries.map((entry) {
      final double percentage = totalAmount == 0 ? 0 : (entry.value / totalAmount) * 100;

      return BookingCategoryStats(
        category: entry.key,
        totalAmount: entry.value,
        percentage: percentage,
      );
    }).toList();

    bookingCategoryStats.sort(
      (a, b) => b.percentage.compareTo(a.percentage),
    );

    return bookingCategoryStats;
  }

  Future<Map<int, List<Booking>>> loadYearlyBookings(int selectedYear, String userId) async {
    final startOfYear = DateTime(selectedYear, 1, 1);
    final endOfYear = DateTime(selectedYear + 1, 1, 1);
    final yearlyBookings = await Supabase.instance.client
        .from('bookings')
        .select()
        .gte('booking_date', startOfYear)
        .lt('booking_date', endOfYear)
        .order('booking_date', ascending: false);
    final List<Booking> allBookings = (yearlyBookings as List).map((data) => Booking.fromMap(data)).toList();
    final Map<int, List<Booking>> monthlyBookings = groupBy(allBookings, (booking) {
      return booking.bookingDate.month;
    });
    return monthlyBookings;
  }

  double calculateRevenue(List<Booking> bookings) {
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

  double calculateExpenses(List<Booking> bookings) {
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
