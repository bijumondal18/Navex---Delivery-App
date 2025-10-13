part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;
  final String pharmacyKey;

  const LoginSubmittedEvent({
    required this.email,
    required this.password,
    required this.pharmacyKey,
  });

  @override
  List<Object> get props => [email, password, pharmacyKey];
}

class FetchUserProfileEvent extends AuthEvent {}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}
