import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking.dart';

class BookingRepository {
  Future<Booking> createBooking(Booking newBooking) async {
    final createdBooking = await Supabase.instance.client.from('bookings').insert(newBooking.toMap()).select().single();
    return Booking.fromMap(createdBooking);
  }
}
