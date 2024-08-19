part of 'auth_bloc.dart';

sealed class AuthEvent {}

final class SendOTP extends AuthEvent {
  final String phoneNumber;

  SendOTP({required this.phoneNumber});
}

final class CreateAccount extends AuthEvent {
  final UserModel userModel;

  CreateAccount({required this.userModel});
}

final class LoginUser extends AuthEvent {
  final String phoneNumber;
  final String password;

  LoginUser({required this.phoneNumber, required this.password});
}
