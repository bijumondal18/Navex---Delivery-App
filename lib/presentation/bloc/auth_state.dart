part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

/**
 * Login States
 * */
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

/**
 * Fetch User Profile States
 * */

final class FetchUserProfileStateLoading extends AuthState {}

final class FetchUserProfileStateLoaded extends AuthState {
  final ProfileResponse profileResponse;

  const FetchUserProfileStateLoaded({required this.profileResponse});

  @override
  List<Object> get props => [profileResponse];
}

final class FetchUserProfileStateFailed extends AuthState {
  final String error;

  const FetchUserProfileStateFailed({required this.error});

  @override
  List<Object> get props => [error];
}

/**
 * Forgot Password Get OTP States Handling
 * */

final class ForgotPasswordStateLoading extends AuthState {}

final class ForgotPasswordStateLoaded extends AuthState {
  final ForgotPasswordResponse forgotPasswordResponse;

  const ForgotPasswordStateLoaded({required this.forgotPasswordResponse});

  @override
  List<Object> get props => [forgotPasswordResponse];
}

final class ForgotPasswordStateFailed extends AuthState {
  final String error;

  const ForgotPasswordStateFailed({required this.error});

  @override
  List<Object> get props => [error];
}

/**
 * Reset Password/ Set new Password States Handling
 * */

final class ResetPasswordStateLoading extends AuthState {}

final class ResetPasswordStateLoaded extends AuthState {
  final ForgotPasswordResponse resetPasswordResponse;

  const ResetPasswordStateLoaded({required this.resetPasswordResponse});

  @override
  List<Object> get props => [resetPasswordResponse];
}

final class ResetPasswordStateFailed extends AuthState {
  final String error;

  const ResetPasswordStateFailed({required this.error});

  @override
  List<Object> get props => [error];
}

/**
 * Update Profile  States Handling
 * */

final class UpdateProfileStateLoading extends AuthState {}

final class UpdateProfileStateLoaded extends AuthState {
  final CommonResponse commonResponse;

  const UpdateProfileStateLoaded({required this.commonResponse});

  @override
  List<Object> get props => [commonResponse];
}

final class UpdateProfileStateFailed extends AuthState {
  final String error;

  const UpdateProfileStateFailed({required this.error});

  @override
  List<Object> get props => [error];
}