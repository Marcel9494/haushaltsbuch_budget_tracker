import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/blocs/user/user_event.dart';
import 'package:haushaltsbuch_budget_tracker/blocs/user/user_state.dart';

import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc(this._userRepository) : super(UserInitial()) {
    on<CreateUser>(_onCreateUser);
    on<LoadUser>(_onLoadUser);
    on<UpdateUserLocale>(_onUpdateUserLocale);
    on<UpdateUserCurrency>(_onUpdateUserCurrency);
    on<UpdateUserHasOnboardingCompleted>(_onUpdateUserHasOnboardingCompleted);
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final User createdUser = await _userRepository.createUser(event.user);
      emit(UserCreated(createdUser));
    } catch (e) {
      emit(UserError('create_user_error'));
    }
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final User user = await _userRepository.loadUser(event.userId);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError('load_user_error'));
    }
  }

  Future<void> _onUpdateUserLocale(UpdateUserLocale event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _userRepository.updateUserLocale(event.userId, event.locale);
      final User updatedUser = await _userRepository.loadUser(event.userId);
      emit(UserLoaded(updatedUser));
    } catch (e) {
      emit(UserError('update_user_locale_error'));
    }
  }

  Future<void> _onUpdateUserCurrency(UpdateUserCurrency event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _userRepository.updateUserCurrency(event.userId, event.currencyCode);
      final User updatedUser = await _userRepository.loadUser(event.userId);
      emit(UserLoaded(updatedUser));
    } catch (e) {
      emit(UserError('update_user_currency_error'));
    }
  }

  Future<void> _onUpdateUserHasOnboardingCompleted(UpdateUserHasOnboardingCompleted event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _userRepository.updateUserHasOnboardingCompleted(event.userId, event.hasOnboardingCompleted);
      emit(UserHasOnboardingCompletedUpdated());
    } catch (e) {
      emit(UserError('update_user_onboarding_completed_error'));
    }
  }
}
