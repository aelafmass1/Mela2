part of 'auth_bloc.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthFail extends AuthState {
  final String reason;

  AuthFail({required this.reason});
}

final class AuthSuccess extends AuthState {}

final class UpdateLoading extends AuthState {}

final class UpdateFail extends AuthState {
  final String reason;

  UpdateFail({required this.reason});
}

final class UpdateSuccess extends AuthState {}

final class OTPVerificationLoading extends AuthState {}

final class OTPVerificationFail extends AuthState {
  final String reason;

  OTPVerificationFail({required this.reason});
}

final class OTPVerificationSuccess extends AuthState {}

final class SendOTPLoading extends AuthState {}

final class SendOTPFail extends AuthState {
  final String reason;

  SendOTPFail({required this.reason});
}

final class SendOTPSuccess extends AuthState {}

final class UploadProfileLoading extends AuthState {}

final class UploadProfileFail extends AuthState {
  final String reason;

  UploadProfileFail({required this.reason});
}

final class UploadProfileSuccess extends AuthState {}

final class RegisterUserLoaing extends AuthState {}

final class RegisterUserFail extends AuthState {
  final String reason;

  RegisterUserFail({required this.reason});
}

final class RegisterUserSuccess extends AuthState {}

final class LoginUserLoading extends AuthState {}

final class LoginUserFail extends AuthState {
  final String reason;

  LoginUserFail({required this.reason});
}

final class LoginUserSuccess extends AuthState {}
