import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:navex/core/utils/app_preference.dart';
import 'package:navex/data/models/common_response.dart';
import 'package:navex/data/models/forgot_password_response.dart';
import 'package:navex/data/models/login_response.dart';
import 'package:navex/data/models/profile_response.dart';
import 'package:navex/data/models/state_details.dart';
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
          final loginResponse = LoginResponse.fromJson(response);

          await AppPreference.setInt(
            AppPreference.userId,
            loginResponse.user?.id ?? 0,
          );

          await AppPreference.setString(
            AppPreference.pharmacyKey,
            loginResponse.pharmacyKey ?? "",
          );

          await AppPreference.setString(
            AppPreference.token,
            loginResponse.token ?? "",
          );

          await AppPreference.setString(
            AppPreference.fullName,
            loginResponse.user?.name ?? "",
          );

          await AppPreference.setString(
            AppPreference.email,
            loginResponse.user?.email ?? "",
          );

          await AppPreference.setBool(AppPreference.isLoggedIn, true);

          emit(LoginStateLoaded(loginResponse: loginResponse));
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

    /**
     * Fetch Profile States Handling
     * */
    on<FetchUserProfileEvent>((event, emit) async {
      emit(FetchUserProfileStateLoading());
      try {
        final response = await authRepository.fetchUserProfile();
        if (response['status'] == true) {
          final profileResponse = ProfileResponse.fromJson(response);
          await AppPreference.setString(
            AppPreference.fullName,
            profileResponse.user?.name ?? '',
          );
          await AppPreference.setString(
            AppPreference.email,
            profileResponse.user?.email ?? '',
          );

          emit(FetchUserProfileStateLoaded(profileResponse: profileResponse));
        } else {
          emit(
            FetchUserProfileStateFailed(
              error: response['message'] ?? "Something went wrong",
            ),
          );
        }
      } catch (e) {
        emit(FetchUserProfileStateFailed(error: e.toString()));
      }
    });

    /**
     * Forgot Password States Handling
     * */
    on<ForgotPasswordEvent>((event, emit) async {
      emit(ForgotPasswordStateLoading());
      try {
        final response = await authRepository.forgotPassword(event.email);
        if (response['status'] == true) {
          final forgotPasswordResponse = ForgotPasswordResponse.fromJson(
            response,
          );

          emit(
            ForgotPasswordStateLoaded(
              forgotPasswordResponse: forgotPasswordResponse,
            ),
          );
        } else {
          emit(
            ForgotPasswordStateFailed(
              error: response['message'] ?? "Something went wrong",
            ),
          );
        }
      } catch (e) {
        emit(ForgotPasswordStateFailed(error: e.toString()));
      }
    });

    /**
     * Forgot Password States Handling
     * */
    on<ResetPasswordEvent>((event, emit) async {
      emit(ResetPasswordStateLoading());
      try {
        final response = await authRepository.resetPassword(
          event.email,
          event.otp,
          event.password,
          event.confirmPassword,
        );
        if (response['status'] == true) {
          final resetPasswordResponse = ForgotPasswordResponse.fromJson(
            response,
          );

          emit(
            ResetPasswordStateLoaded(
              resetPasswordResponse: resetPasswordResponse,
            ),
          );
        } else {
          emit(
            ResetPasswordStateFailed(
              error: response['message'] ?? "Something went wrong",
            ),
          );
        }
      } catch (e) {
        emit(ResetPasswordStateFailed(error: e.toString()));
      }
    });

    /**
     * Forgot Password States Handling
     * */
    on<UpdateProfileEvent>((event, emit) async {
      emit(UpdateProfileStateLoading());
      try {
        final response = await authRepository.updateUserProfile(
          event.name,
          event.email,
          event.phoneNumber,
          event.bio,
          event.address,
          event.city,
          event.zipCode,
          event.stateId,
          profileImage: event.profileImage,
        );
        if (response['status'] == true) {
          final commonResponse = CommonResponse.fromJson(response);

          emit(UpdateProfileStateLoaded(commonResponse: commonResponse));
          add(FetchUserProfileEvent());
        } else {
          emit(
            UpdateProfileStateFailed(
              error: response['message'] ?? "Something went wrong",
            ),
          );
        }
      } catch (e) {
        emit(UpdateProfileStateFailed(error: e.toString()));
      }
    });

    /**
     * Fetch Profile States Handling
     * */
    on<FetchStateListEvent>((event, emit) async {
      emit(FetchStateListStateLoading());
      try {
        final response = await authRepository.fetchStateList();
        final List<StateDetails> stateList = (response as List)
            .map((e) => StateDetails.fromJson(e))
            .toList();
        emit(FetchStateListStateLoaded(stateList: stateList));
      } catch (e) {
        emit(FetchStateListStateFailed(error: e.toString()));
      }
    });
  }
}
