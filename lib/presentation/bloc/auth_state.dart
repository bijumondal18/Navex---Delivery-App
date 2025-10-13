part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class LoginStateLoading extends AuthState {}

final class LoginStateLoaded extends AuthState {
  final LoginResponse loginResponse;

  const LoginStateLoaded({required this.loginResponse});

  @override
  List<Object> get props => [loginResponse];
}

final class LoginStateFailed extends AuthState {
  final String error;

  const LoginStateFailed({required this.error});

  @override
  List<Object> get props => [error];
}
