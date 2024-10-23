part of 'auth_bloc.dart';

sealed class AuthEvent {}

final class SendOTP extends AuthEvent {
  final int phoneNumber;
  final int countryCode;
  final String signature;

  SendOTP({
    required this.phoneNumber,
    required this.countryCode,
    required this.signature,
  });
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
  final int phoneNumber;
  final int conutryCode;
  final String code;

  VerfiyOTP({
    required this.phoneNumber,
    required this.code,
    required this.conutryCode,
  });
}

final class UploadProfilePicture extends AuthEvent {
  final XFile profilePicture;
  final String phoneNumber;

  UploadProfilePicture(
      {required this.profilePicture, required this.phoneNumber});
}

final class LoginWithPincode extends AuthEvent {
  final String pincode;

  LoginWithPincode({required this.pincode});
}

final class SendOTPForPasswordReset extends AuthEvent {
  final int phoneNumber;
  final int countryCode;
  final String signature;

  SendOTPForPasswordReset({
    required this.phoneNumber,
    required this.countryCode,
    required this.signature,
  });
}

final class SendOTPForPincodeReset extends AuthEvent {
  final int phoneNumber;
  final int countryCode;
  final String signature;
  final String accessToken;

  SendOTPForPincodeReset({
    required this.phoneNumber,
    required this.countryCode,
    required this.signature,
    required this.accessToken,
  });
}

final class ResetPassword extends AuthEvent {
  final int phoneNumber;
  final String otp;
  final int countryCode;
  final String newPassword;

  ResetPassword({
    required this.phoneNumber,
    required this.otp,
    required this.countryCode,
    required this.newPassword,
  });
}

final class ResetPincode extends AuthEvent {
  final int phoneNumber;
  final String otp;
  final int countryCode;
  final String newPincode;

  ResetPincode({
    required this.phoneNumber,
    required this.otp,
    required this.countryCode,
    required this.newPincode,
  });
}

final class CheckEmailExists extends AuthEvent {
  final String email;

  CheckEmailExists({required this.email});
}
