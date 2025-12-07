import 'package:bloc/bloc.dart';

import '../../data/models/booking.dart';
import '../../data/repositories/booking_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;

  BookingBloc(this._bookingRepository) : super(BookingInitial()) {
    on<CreateBooking>(_onCreateBooking);
    on<LoadMonthlyBookings>(_onLoadMonthlyBookings);
    on<LoadYearlyBookings>(_onLoadYearlyBookings);
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

  Future<void> _onLoadMonthlyBookings(LoadMonthlyBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final List<Booking> monthlyBookings = await _bookingRepository.loadMonthlyBookings(event.selectedDate, event.userId);
      emit(BookingListLoaded(monthlyBookings));
    } catch (e) {
      emit(BookingError('load_bookings_error'));
    }
  }

  Future<void> _onLoadYearlyBookings(LoadYearlyBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final Map<int, List<Booking>> yearlyBookings = await _bookingRepository.loadYearlyBookings(event.selectedYear, event.userId);
      emit(YearlyBookingListLoaded(yearlyBookings));
    } catch (e) {
      emit(BookingError('load_bookings_error'));
    }
  }
}
