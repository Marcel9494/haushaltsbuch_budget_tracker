import 'package:bloc/bloc.dart';

import '../../data/models/booking.dart';
import '../../data/repositories/booking_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;

  BookingBloc(this._bookingRepository) : super(BookingInitial()) {
    on<CreateBooking>(_onCreateBooking);
  }

  Future<void> _onCreateBooking(CreateBooking event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final Booking createdBooking = await _bookingRepository.createBooking(event.booking);
      emit(BookingCreated(createdBooking));
    } catch (e) {
      emit(BookingError('create_booking_error'));
    }
  }
}
