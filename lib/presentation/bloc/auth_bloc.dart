import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:navex/data/models/login_response.dart';
import 'package:navex/data/repositories/auth_repository.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    /**
     * Login Event Handler
     * */
    on<LoginSubmittedEvent>((event, emit) async {
      emit(LoginStateLoading());
      try {
        final response = await authRepository.login(
          event.email,
          event.password,
          event.pharmacyKey,
        );
        if (response['status'] == true) {
          emit(
            LoginStateLoaded(loginResponse: LoginResponse.fromJson(response)),
          );
        } else {
          emit(
            LoginStateFailed(
              error: response['message'] ?? "Something went wrong",
            ),
          );
        }
      } catch (e) {
        emit(LoginStateFailed(error: e.toString()));
      }
    });
  }
}
