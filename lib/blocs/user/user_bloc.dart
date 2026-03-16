import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/blocs/user/user_event.dart';
import 'package:haushaltsbuch_budget_tracker/blocs/user/user_state.dart';

import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc(this._userRepository) : super(UserInitial()) {
    on<CreateUser>(_onCreateUser);
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
}
