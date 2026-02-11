import 'package:bloc/bloc.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/account_repository.dart';

import '../../data/helper_models/booking_category_stats.dart';
import '../../data/models/booking.dart';
import '../../data/repositories/booking_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;
  final AccountRepository _accountRepository;

  BookingBloc(this._bookingRepository, this._accountRepository) : super(BookingInitial()) {
    on<CreateBooking>(_onCreateBooking);
    on<UpdateBooking>(_onUpdateBooking);
    on<DeleteBooking>(_onDeleteBooking);
    on<LoadMonthlyBookings>(_onLoadMonthlyBookings);
    on<LoadYearlyBookings>(_onLoadYearlyBookings);
  }

  Future<void> _onCreateBooking(CreateBooking event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final List<Booking> createdBookings = await _bookingRepository.createBooking(event.booking);
      _accountRepository.updateAccountBalance(createdBookings);
      emit(BookingCreated());
    } catch (e) {
      emit(BookingError('create_booking_error'));
    }
  }

  Future<void> _onUpdateBooking(UpdateBooking event, Emitter<BookingState> emit) async {
    try {
      final Booking updatedBooking = await _bookingRepository.updateBooking(event.booking);
      emit(BookingUpdated(updatedBooking));
    } catch (e) {
      emit(BookingError('update_booking_error'));
    }
  }

  Future<void> _onDeleteBooking(DeleteBooking event, Emitter<BookingState> emit) async {
    try {
      await _bookingRepository.deleteBooking(event.bookingId);
      final monthlyBookings = await _bookingRepository.loadMonthlyBookings(DateTime.now());
      emit(BookingListLoaded(monthlyBookings));
    } catch (e) {
      emit(BookingError('delete_booking_error'));
    }
  }

  Future<void> _onLoadMonthlyBookings(LoadMonthlyBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final List<Booking> monthlyBookings = await _bookingRepository.loadMonthlyBookings(event.selectedDate);
      emit(BookingListLoaded(monthlyBookings));
    } catch (e) {
      emit(BookingError('load_bookings_error'));
    }
  }

  Future<void> _onLoadYearlyBookings(LoadYearlyBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final Map<int, List<Booking>> yearlyBookings = await _bookingRepository.loadYearlyBookings(event.selectedYear);
      emit(YearlyBookingListLoaded(yearlyBookings));
    } catch (e) {
      emit(BookingError('load_bookings_error'));
    }
  }
}
