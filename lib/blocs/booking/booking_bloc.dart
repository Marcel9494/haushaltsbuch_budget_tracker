import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/booking_selection_type.dart';
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
    on<LoadGoalBookings>(_onLoadGoalBookings);
  }

  Future<void> _onCreateBooking(CreateBooking event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final List<Booking> createdBookings = await _bookingRepository.createBooking(event.booking);
      if (event.updateAccountBalance) {
        _accountRepository.updateAccountBalance(createdBookings, event.context);
      }
      emit(BookingCreated());
    } catch (e) {
      emit(BookingError('create_booking_error'));
    }
  }

  Future<void> _onUpdateBooking(UpdateBooking event, Emitter<BookingState> emit) async {
    try {
      if (event.bookingSelectionType == BookingSelectionType.single) {
        await _accountRepository.reverseAccountBalance(event.oldBooking, event.context);
        List<Booking> booking = [event.newBooking];
        _accountRepository.updateAccountBalance(booking, event.context);
        await _bookingRepository.updateBooking(event.newBooking);
      } else if (event.bookingSelectionType == BookingSelectionType.onlyFuture) {
        // 1. Nur zukünftige Buchungen laden und Kontostand rückgängig machen
        final List<Booking> loadedFutureRepetitionBookings =
            await _bookingRepository.loadFutureRepetitionBookings(event.oldBooking.repetitionId!, event.oldBooking.bookingDate);
        for (Booking booking in loadedFutureRepetitionBookings) {
          await _accountRepository.reverseAccountBalance(booking, event.context);
        }
        // 2. Zukünftige Buchungen mit neuen Daten aktualisieren und neuen Kontostand berechnen
        final List<Booking> newLoadedFutureRepetitionBookings = await _bookingRepository.updateFutureRepetitionBookings(event.newBooking);
        _accountRepository.updateAccountBalance(newLoadedFutureRepetitionBookings, event.context);
      } else if (event.bookingSelectionType == BookingSelectionType.all) {
        // 1. Buchungen laden und Kontostand rückgängig machen
        final List<Booking> loadedRepetitionBookings = await _bookingRepository.loadRepetitionBookings(event.oldBooking.repetitionId!);
        for (Booking booking in loadedRepetitionBookings) {
          await _accountRepository.reverseAccountBalance(booking, event.context);
        }
        // 2. Buchungen mit neuen Daten aktualisieren und neuen Kontostand berechnen
        final List<Booking> newLoadedRepetitionBookings = await _bookingRepository.updateRepetitionBookings(event.newBooking);
        _accountRepository.updateAccountBalance(newLoadedRepetitionBookings, event.context);
      }
      emit(BookingUpdated());
    } catch (e) {
      emit(BookingError('update_booking_error'));
    }
  }

  Future<void> _onDeleteBooking(DeleteBooking event, Emitter<BookingState> emit) async {
    try {
      if (event.bookingSelectionType == BookingSelectionType.single) {
        await _accountRepository.reverseAccountBalance(event.booking, event.context);
        await _bookingRepository.deleteBooking(event.booking.id!);
      } else if (event.bookingSelectionType == BookingSelectionType.onlyFuture) {
        final List<Booking> loadedFutureRepetitionBookings =
            await _bookingRepository.loadFutureRepetitionBookings(event.booking.repetitionId!, event.booking.bookingDate);
        await _accountRepository.reverseAccountBalances(loadedFutureRepetitionBookings);
        await _bookingRepository.deleteFutureRepetitionBookings(event.booking.repetitionId!, event.booking.bookingDate);
      } else if (event.bookingSelectionType == BookingSelectionType.all) {
        final List<Booking> loadedRepetitionBookings = await _bookingRepository.loadRepetitionBookings(event.booking.repetitionId!);
        await _accountRepository.reverseAccountBalances(loadedRepetitionBookings);
        await _bookingRepository.deleteRepetitionBookings(event.booking.repetitionId!);
      }
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

  _onLoadGoalBookings(LoadGoalBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final List<Booking> goalBookings = await _bookingRepository.loadGoalBookings();
      emit(BookingListLoaded(goalBookings));
    } catch (e) {
      emit(BookingError('load_goal_bookings_error'));
    }
  }
}
