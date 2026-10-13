import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_de.dart';
import '../../l10n/app_en.dart';
import '../helper_models/net_worth_booking.dart';

class NetWorthRepository {
  // Supabase liefert standardmäßig maximal 1000 Zeilen pro Anfrage.
  static const int _pageSize = 1000;

  // Titel der automatisch erzeugten Saldoanpassungs-Buchungen in allen Sprachen.
  static final Set<String> _balanceAdjustmentTitles = {
    if (de['balance_adjustment'] != null) de['balance_adjustment']!,
    if (en['balance_adjustment'] != null) en['balance_adjustment']!,
  };

  // Lädt alle bereits gebuchten Buchungen (is_booked = true) des Nutzers.
  // Es werden nur die Spalten geladen, die für die Vermögensentwicklung benötigt werden.
  Future<List<NetWorthBooking>> loadBookedBookings() async {
    final SupabaseClient supabase = Supabase.instance.client;
    final String? userId = supabase.auth.currentUser?.id;
    final List<NetWorthBooking> bookings = [];

    int from = 0;
    while (true) {
      var query = supabase
          .from('bookings')
          .select('id, booking_type, amount, booking_date, debit_account_id, target_account_id, category_id, title, is_booked')
          .eq('is_booked', true);
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      final List<dynamic> rows = await query.order('booking_date', ascending: true).order('id', ascending: true).range(from, from + _pageSize - 1);

      bookings.addAll(rows.map((row) => NetWorthBooking.fromMap(
            row as Map<String, dynamic>,
            balanceAdjustmentTitles: _balanceAdjustmentTitles,
          )));

      if (rows.length < _pageSize) {
        break;
      }
      from += _pageSize;
    }
    return bookings;
  }
}
