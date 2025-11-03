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

class FetchStateListEvent extends AuthEvent {}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String otp;
  final String password;
  final String confirmPassword;

  const ResetPasswordEvent({
    required this.email,
    required this.otp,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [email, otp, password, confirmPassword];
}

class UpdateProfileEvent extends AuthEvent {
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? bio;
  final String? address;
  final String? city;
  final String? zipCode;
  final String? stateId;

  const UpdateProfileEvent({
    this.name,
    this.email,
    this.phoneNumber,
    this.bio,
    this.address,
    this.city,
    this.zipCode,
    this.stateId,
  });

  @override
  List<Object> get props => [
    name ?? '',
    email ?? '',
    phoneNumber ?? '',
    bio ?? '',
    address ?? '',
    city ?? '',
    zipCode ?? '',
    stateId ?? '',
  ];
}
