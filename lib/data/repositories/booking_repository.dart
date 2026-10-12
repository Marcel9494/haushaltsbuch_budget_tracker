import 'package:collection/collection.dart';
import 'package:haushaltsbuch_budget_tracker/data/helper_models/booking_category_stats.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/consts/repeat_number_consts.dart';
import '../../core/utils/date_helper.dart';
import '../enums/amount_type.dart';
import '../enums/booking_type.dart';
import '../enums/repetition_type.dart';
import '../helper_models/amount_type_stats.dart';
import '../models/booking.dart';

class BookingRepository {
  Future<List<Booking>> createBooking(Booking newBooking) async {
    final supabase = Supabase.instance.client;
    if (newBooking.repetitionType == RepetitionType.noRepetition) {
      final createdBookings = await Supabase.instance.client.from('bookings').insert(newBooking.toMap()).select();
      return createdBookings.map<Booking>((e) => Booking.fromMap(e)).toList();
    } else {
      final createdBookingsMap = <Map<String, dynamic>>[];

      final repetitionBookingId = const Uuid().v4();

      final baseBookingMap = Map<String, dynamic>.from(
        newBooking.toMap(),
      )..['repetition_id'] = repetitionBookingId;

      for (final DateTime bookingDate in getRepetitionDates(newBooking.bookingDate, newBooking.repetitionType)) {
        createdBookingsMap.add({
          ...baseBookingMap,
          'booking_date': toDateOnlyString(bookingDate),
          'is_booked': getIsBookingDateBefore(bookingDate),
        });
      }

      final createdBookings = await supabase.from('bookings').insert(createdBookingsMap).select();
      return createdBookings.map<Booking>((e) => Booking.fromMap(e)).toList();
    }
  }

  Future<List<Booking>> updateBooking(Booking booking) async {
    final SupabaseClient supabase = Supabase.instance.client;

    if (booking.repetitionType == RepetitionType.noRepetition) {
      // Normales Buchungsupdate
      final updatedBooking = await supabase
          .from('bookings')
          .update(booking.toMap())
          .eq('id', booking.id!)
          .eq('user_id', supabase.auth.currentUser!.id)
          .select()
          .single();
      return [Booking.fromMap(updatedBooking)];
    }

    // Wiederholungsbuchungen updaten
    final repetitionBookingId = const Uuid().v4();

    // Bestehende Buchung zur ersten Buchung der Serie machen
    final updatedFirstBooking = await supabase
        .from('bookings')
        .update({
          ...booking.toMap(),
          'repetition_id': repetitionBookingId,
          'booking_date': toDateOnlyString(booking.bookingDate),
        })
        .eq('id', booking.id!)
        .eq('user_id', supabase.auth.currentUser!.id)
        .select()
        .single();

    final updatedBooking = Booking.fromMap(updatedFirstBooking);

    // Weitere Wiederholungsbuchungen erzeugen
    final bookingRepetitions = await _createBookingRepetitions(
      booking,
      skipFirst: true,
      repetitionId: repetitionBookingId,
    );

    return [updatedBooking, ...bookingRepetitions];
  }

  Future<List<Booking>> _createBookingRepetitions(Booking booking, {bool skipFirst = false, String? repetitionId}) async {
    final SupabaseClient supabase = Supabase.instance.client;
    final createdBookingsMap = <Map<String, dynamic>>[];
    final repetitionBookingId = repetitionId ?? const Uuid().v4();
    final baseBookingMap = Map<String, dynamic>.from(
      booking.toMap(),
    )..['repetition_id'] = repetitionBookingId;

    // skipFirst: Die bereits existierende Buchung überspringen
    for (final DateTime bookingDate in getRepetitionDates(booking.bookingDate, booking.repetitionType, skipFirst: skipFirst)) {
      createdBookingsMap.add({
        ...baseBookingMap,
        'booking_date': toDateOnlyString(bookingDate),
        'is_booked': getIsBookingDateBefore(bookingDate),
      });
    }

    if (createdBookingsMap.isEmpty) {
      return [];
    }

    final createdBookings = await supabase.from('bookings').insert(createdBookingsMap).select();
    return createdBookings.map<Booking>((e) => Booking.fromMap(e)).toList();
  }

  Future<List<Booking>> updateFutureRepetitionBookings(Booking updatedBooking) async {
    final supabase = Supabase.instance.client;
    final repetitionId = updatedBooking.repetitionId!;
    final startDate = DateTime(
      updatedBooking.bookingDate.year,
      updatedBooking.bookingDate.month,
      updatedBooking.bookingDate.day,
    );

    // ==========================================================
    // Keine Wiederholung
    // ==========================================================
    if (updatedBooking.repetitionType == RepetitionType.noRepetition) {
      // 1. Alle zukünftigen Buchungen der Serie löschen,
      //    außer der aktuell bearbeiteten Buchung
      await supabase.from('bookings').delete().eq('repetition_id', repetitionId).gt(
            'booking_date',
            toDateOnlyString(startDate),
          );

      // 2. Aktuelle Buchung in eine normale Einzelbuchung umwandeln
      final updatedBookingMap = Map<String, dynamic>.from(
        updatedBooking.toMap(),
      )..['repetition_id'] = null;

      final result = await supabase.from('bookings').update(updatedBookingMap).eq('id', updatedBooking.id!).select();
      return result.map<Booking>((e) => Booking.fromMap(e)).toList();
    }

    // ==========================================================
    // Normale Änderung der zukünftigen Wiederholungen
    // ==========================================================

    // 1. Alle zukünftigen Buchungen löschen
    await supabase.from('bookings').delete().eq('repetition_id', repetitionId).gte(
          'booking_date',
          toDateOnlyString(startDate),
        );

    // 2. Neue zukünftige Buchungen generieren
    final createdBookingsMap = <Map<String, dynamic>>[];

    final baseBookingMap = Map<String, dynamic>.from(
      updatedBooking.toMap(),
    )..['repetition_id'] = repetitionId;

    for (final DateTime bookingDate in getRepetitionDates(startDate, updatedBooking.repetitionType)) {
      createdBookingsMap.add({
        ...baseBookingMap,
        'booking_date': toDateOnlyString(bookingDate),
        'is_booked': getIsBookingDateBefore(bookingDate),
      });
    }

    // 3. Neue Serie erstellen
    final createdBookings = await supabase.from('bookings').insert(createdBookingsMap).select();
    return createdBookings.map<Booking>((e) => Booking.fromMap(e)).toList();
  }

  Future<List<Booking>> updateRepetitionBookings(Booking updatedBooking) async {
    final supabase = Supabase.instance.client;
    final repetitionId = updatedBooking.repetitionId!;

    // Benutzer setzt die Wiederholung auf "Keine Wiederholung"
    if (updatedBooking.repetitionType == RepetitionType.noRepetition) {
      // 1. Alle anderen Buchungen der Serie löschen
      await supabase.from('bookings').delete().eq('repetition_id', repetitionId).neq('id', updatedBooking.id!);

      // 2. Die aktuelle Buchung aktualisieren
      final updatedBookingMap = Map<String, dynamic>.from(
        updatedBooking.toMap(),
      )..['repetition_id'] = null;

      final result = await supabase.from('bookings').update(updatedBookingMap).eq('id', updatedBooking.id!).select();
      return result.map<Booking>((e) => Booking.fromMap(e)).toList();
    }

    // ----------------------------------------------------------
    // Normale Änderung einer Wiederholungsbuchung
    // ----------------------------------------------------------

    // 1. Alle Buchungen dieser Serie löschen
    await supabase.from('bookings').delete().eq('repetition_id', repetitionId);

    // 2. Neue Serie generieren
    final createdBookingsMap = <Map<String, dynamic>>[];

    final baseBookingMap = Map<String, dynamic>.from(
      updatedBooking.toMap(),
    )..['repetition_id'] = repetitionId;

    for (final DateTime bookingDate in getRepetitionDates(updatedBooking.bookingDate, updatedBooking.repetitionType)) {
      createdBookingsMap.add({
        ...baseBookingMap,
        'booking_date': toDateOnlyString(bookingDate),
        'is_booked': getIsBookingDateBefore(bookingDate),
      });
    }

    // 3. Neue Serie erstellen
    final createdBookings = await supabase.from('bookings').insert(createdBookingsMap).select();
    return createdBookings.map<Booking>((e) => Booking.fromMap(e)).toList();
  }

  Future<void> updateBookingAmountsWithExchangeRate(String userId, double exchangeRate) async {
    final supabase = Supabase.instance.client;
    final bookings = await supabase.from('bookings').select('id, amount').eq('user_id', userId);
    for (final booking in bookings) {
      final amount = (booking['amount'] as num?)?.toDouble() ?? 0;
      await supabase.from('bookings').update({'amount': amount * exchangeRate}).eq('id', booking['id']).eq('user_id', userId);
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    final SupabaseClient supabase = Supabase.instance.client;
    await supabase.from('bookings').delete().eq('id', bookingId).eq('user_id', supabase.auth.currentUser!.id).select().single();
  }

  Future<void> deleteFutureRepetitionBookings(String repetitionId, DateTime fromDate) async {
    final SupabaseClient supabase = Supabase.instance.client;
    await supabase
        .from('bookings')
        .delete()
        .eq('repetition_id', repetitionId)
        .gte('booking_date', toDateOnlyString(fromDate))
        .eq('user_id', supabase.auth.currentUser!.id);
  }

  Future<void> deleteRepetitionBookings(String repetitionId) async {
    final SupabaseClient supabase = Supabase.instance.client;
    await supabase.from('bookings').delete().eq('repetition_id', repetitionId).eq('user_id', supabase.auth.currentUser!.id);
  }

  Future<Booking> loadBooking(String bookingId) async {
    final SupabaseClient supabase = Supabase.instance.client;
    final booking = await supabase.from('bookings').select().eq('id', bookingId).eq('user_id', supabase.auth.currentUser!.id).single();
    return Booking.fromMap(booking);
  }

  Future<List<Booking>> loadFutureRepetitionBookings(String repetitionId, DateTime fromDate) async {
    final futureRepetitionBookings = await Supabase.instance.client
        .from('bookings')
        .select()
        .eq('repetition_id', repetitionId)
        .gte('booking_date', toDateOnlyString(fromDate))
        .order('booking_date');
    return (futureRepetitionBookings as List).map((data) => Booking.fromMap(data)).toList();
  }

  Future<List<Booking>> loadRepetitionBookings(String repetitionId) async {
    final repetitionBookings = await Supabase.instance.client.from('bookings').select().eq('repetition_id', repetitionId).order('booking_date');
    return (repetitionBookings as List).map((data) => Booking.fromMap(data)).toList();
  }

  Future<List<Booking>> loadMonthlyBookings(DateTime selectedDate) async {
    final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    final monthlyBookings = await Supabase.instance.client
        .from('bookings')
        .select(
            '*, categories(*), debit_account:accounts!bookings_debit_account_id_fkey(*), target_account:accounts!bookings_target_account_id_fkey(*), goals(*)')
        .gte('booking_date', toDateOnlyString(startOfMonth))
        .lt('booking_date', toDateOnlyString(endOfMonth))
        .order('booking_date', ascending: false);
    return (monthlyBookings as List).map((data) => Booking.fromMap(data)).toList();
  }

  Future<Map<int, List<Booking>>> loadYearlyBookings(int selectedYear) async {
    final startOfYear = DateTime(selectedYear, 1, 1);
    final endOfYear = DateTime(selectedYear + 1, 1, 1);
    final yearlyBookings = await Supabase.instance.client
        .from('bookings')
        .select(
            '*, categories(*), debit_account:accounts!bookings_debit_account_id_fkey(*), target_account:accounts!bookings_target_account_id_fkey(*), goals(*)')
        .gte('booking_date', toDateOnlyString(startOfYear))
        .lt('booking_date', toDateOnlyString(endOfYear))
        .order('booking_date', ascending: false);
    final List<Booking> allBookings = (yearlyBookings as List).map((data) => Booking.fromMap(data)).toList();
    final Map<int, List<Booking>> groupedMonthlyBookings = groupBy(allBookings, (booking) {
      return booking.bookingDate.month;
    });
    return groupedMonthlyBookings;
  }

  Future<List<Booking>> loadGoalBookings() async {
    final goalBookings = await Supabase.instance.client
        .from('bookings')
        .select(
            '*, categories(*), debit_account:accounts!bookings_debit_account_id_fkey(*), target_account:accounts!bookings_target_account_id_fkey(*), goals(*)')
        .not('goal_id', 'is', null)
        .order('booking_date', ascending: false);
    final List<Booking> allGoalBookings = (goalBookings as List).map((data) => Booking.fromMap(data)).toList();
    return allGoalBookings;
  }

  List<BookingCategoryStats> calculateBookingsByCategory(List<Booking> bookings, BookingType selectedBookingType, String selectedAmountType) {
    final Map<String, double> categoryAmount = {};
    for (final booking in bookings) {
      if (selectedAmountType == 'overall') {
        if (booking.bookingType == selectedBookingType && booking.bookingType != BookingType.transfer) {
          if (booking.category == null) {
            categoryAmount['no_category'] = (categoryAmount['no_category'] ?? 0) + booking.amount;
          } else {
            categoryAmount[booking.category!.categoryName] = (categoryAmount[booking.category!.categoryName] ?? 0) + booking.amount;
          }
        }
      } else {
        if (booking.bookingType == selectedBookingType &&
            booking.bookingType != BookingType.transfer &&
            booking.amountType.name == selectedAmountType) {
          if (booking.category == null) {
            categoryAmount['no_category'] = (categoryAmount['no_category'] ?? 0) + booking.amount;
          } else {
            categoryAmount[booking.category!.categoryName] = (categoryAmount[booking.category!.categoryName] ?? 0) + booking.amount;
          }
        }
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

    bookingCategoryStats.sort((a, b) => b.percentage.compareTo(a.percentage));
    return bookingCategoryStats;
  }

  List<AmountTypeStats> calculateBookingsByIncomeAmountType(List<Booking> bookings) {
    double activeIncome = 0;
    double passiveIncome = 0;

    for (final booking in bookings) {
      if (booking.amountType == AmountType.active) {
        activeIncome += booking.amount;
      } else if (booking.amountType == AmountType.passive) {
        passiveIncome += booking.amount;
      }
    }

    final double totalAmountIncome = activeIncome + passiveIncome;
    final double passivePercentage = totalAmountIncome == 0 ? 0 : (passiveIncome / totalAmountIncome) * 100;
    final double activePercentage = totalAmountIncome == 0 ? 0 : (activeIncome / totalAmountIncome) * 100;

    return [
      AmountTypeStats(
        amount: totalAmountIncome,
        percentage: 100.0,
        name: 'overall',
      ),
      AmountTypeStats(
        amount: activeIncome,
        percentage: activePercentage,
        name: AmountType.active.name,
      ),
      AmountTypeStats(
        amount: passiveIncome,
        percentage: passivePercentage,
        name: AmountType.passive.name,
      ),
    ];
  }

  List<AmountTypeStats> calculateBookingsByExpensesAmountType(List<Booking> bookings) {
    double variableExpenses = 0;
    double fixExpenses = 0;

    for (final booking in bookings) {
      if (booking.amountType == AmountType.variable) {
        variableExpenses += booking.amount;
      } else if (booking.amountType == AmountType.fix) {
        fixExpenses += booking.amount;
      }
    }

    final double totalAmountExpenses = variableExpenses + fixExpenses;
    final double fixPercentage = totalAmountExpenses == 0 ? 0 : (fixExpenses / totalAmountExpenses) * 100;
    final double variablePercentage = totalAmountExpenses == 0 ? 0 : (variableExpenses / totalAmountExpenses) * 100;

    return [
      AmountTypeStats(
        amount: totalAmountExpenses,
        percentage: 100.0,
        name: 'overall',
      ),
      AmountTypeStats(
        amount: variableExpenses,
        percentage: variablePercentage,
        name: AmountType.variable.name,
      ),
      AmountTypeStats(
        amount: fixExpenses,
        percentage: fixPercentage,
        name: AmountType.fix.name,
      ),
    ];
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

  Map<int, List<Booking>> groupBookingsByDay(List<Booking> bookings) {
    final grouped = <int, List<Booking>>{};

    for (final booking in bookings) {
      grouped.putIfAbsent(booking.bookingDate.day, () => []).add(booking);
    }

    return grouped;
  }

  // Liefert alle Buchungsdaten einer Wiederholungsserie für die nächsten bookingRepetitionNumberInYears Jahre.
  // Der Starttag wird als anchorDay mitgegeben, damit z.B. eine Serie ab dem 31. nach dem Februar wieder am 31. bucht.
  List<DateTime> getRepetitionDates(DateTime startDate, RepetitionType repetitionType, {bool skipFirst = false}) {
    final DateTime firstBookingDate = DateTime(startDate.year, startDate.month, startDate.day);
    if (repetitionType == RepetitionType.noRepetition) {
      return skipFirst ? [] : [firstBookingDate];
    }

    final DateTime endDate = DateTime(
      firstBookingDate.year + bookingRepetitionNumberInYears,
      firstBookingDate.month,
      firstBookingDate.day,
    );

    final List<DateTime> repetitionDates = [];
    DateTime currentBookingDate = firstBookingDate;
    while (currentBookingDate.isBefore(endDate)) {
      repetitionDates.add(currentBookingDate);
      currentBookingDate = RepetitionType.getNextBookingDate(
        currentBookingDate,
        repetitionType,
        anchorDay: firstBookingDate.day,
      );
    }

    if (skipFirst && repetitionDates.isNotEmpty) {
      repetitionDates.removeAt(0);
    }
    return repetitionDates;
  }

  bool getIsBookingDateBefore(DateTime bookingDate) {
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    return bookingDate.isBefore(tomorrow);
  }

  int getNumberOfRevenueBookings(List<Booking> bookings) {
    int numberOfRevenueBookings = 0;
    for (Booking booking in bookings) {
      if (booking.bookingType == BookingType.income) {
        numberOfRevenueBookings++;
      }
    }
    return numberOfRevenueBookings;
  }

  int getNumberOfExpenseBookings(List<Booking> bookings) {
    int numberOfExpenseBookings = 0;
    for (Booking booking in bookings) {
      if (booking.bookingType == BookingType.expense) {
        numberOfExpenseBookings++;
      }
    }
    return numberOfExpenseBookings;
  }

  int getNumberOfTransferBookings(List<Booking> bookings) {
    int numberOfTransferBookings = 0;
    for (Booking booking in bookings) {
      if (booking.bookingType == BookingType.transfer) {
        numberOfTransferBookings++;
      }
    }
    return numberOfTransferBookings;
  }
}
