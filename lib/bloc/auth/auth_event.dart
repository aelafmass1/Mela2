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
  final int countryCode;

  LoginUser(
      {required this.phoneNumber,
      required this.password,
      required this.countryCode});
}

final class DeleteUser extends AuthEvent {}

final class UpdateUser extends AuthEvent {
  final String fullName;
  final String email;

  UpdateUser({required this.fullName, required this.email});
}

final class VerfiyOTP extends AuthEvent {
  final String phoneNumber;
  final String code;

  VerfiyOTP({required this.phoneNumber, required this.code});
}

final class UploadProfilePicture extends AuthEvent {
  final XFile profilePicture;
  final String phoneNumber;

  UploadProfilePicture(
      {required this.profilePicture, required this.phoneNumber});
}
