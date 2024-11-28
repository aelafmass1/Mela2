import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/core/exceptions/server_exception.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';

import '../../data/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthRepository repository;
  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<SendOTP>(_onSendOTP);
    on<CreateAccount>(_onCreateAccount);
    on<LoginUser>(_onLoginUser);
    on<DeleteUser>(_onDeleteUser);
    on<UpdateUser>(_onUpdateUser);
    on<VerfiyOTP>(_onVerifyOTP);
    on<UploadProfilePicture>(_onUploadProfilePicture);
    on<LoginWithPincode>(_onLoginWithPincode);
    on<SendOTPForPasswordReset>(_onSendOTPForPasswordReset);
    on<SendOTPForPincodeReset>(_onSendOTPForPincodeReset);
    on<ResetPassword>(_onResetPassword);
    on<ResetPincode>(_onResetPincode);
    on<CheckEmailExists>(_onCheckEmailExists);
  }

  /// Handles the logic for checking if an email already exists.
  ///
  /// This method is called when the `CheckEmailExists` event is dispatched.
  /// It first checks if the current state is not `CheckEmailExistsLoading`, and if so, it emits
  /// the `CheckEmailExistsLoading` state. It then calls the `checkEmailExists` method
  /// of the `AuthRepository` to check if the email exists. If the response contains an 'error' key,
  /// it emits the `CheckEmailExistsFail` state with the error reason. Otherwise, it emits the
  /// `CheckEmailExistsSuccess` state.
  ///
  /// If an error occurs during the process, it logs the error and emits the `CheckEmailExistsFail`
  /// state with the error message.
  _onCheckEmailExists(CheckEmailExists event, Emitter emit) async {
    try {
      if (state is! CheckEmailExistsLoading) {
        emit(CheckEmailExistsLoading());
        final res = await repository.checkEmailExists(event.email.trim());
        if (res.containsKey('error')) {
          return emit(CheckEmailExistsFail(reason: res['error']));
        }
        emit(CheckEmailExistsSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(CheckEmailExistsFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(CheckEmailExistsFail(reason: error.toString()));
    }
  }

  /// Handles the logic for sending an OTP (One-Time Password) for password reset.
  ///
  /// This method is called when the `SendOTPForPasswordReset` event is dispatched.
  /// It first checks if the current state is not `SendOTPLoading`, and if so, it emits
  /// the `SendOTPLoading` state. It then calls the `sendOtpForPasswordReset` method
  /// of the `AuthRepository` to send the OTP. If the response contains an 'error' key,
  /// it emits the `SendOTPFail` state with the error reason. Otherwise, it emits the
  /// `SendOTPSuccess` state.
  ///
  /// If an error occurs during the process, it logs the error and emits the `SendOTPFail`
  /// state with the error message.
  _onSendOTPForPasswordReset(
    SendOTPForPasswordReset event,
    Emitter emit,
  ) async {
    try {
      if (state is! SendOTPLoading) {
        emit(SendOTPLoading());
        final res = await repository.sendOtpForPasswordReset(
          event.phoneNumber,
          event.countryCode,
          event.signature,
        );
        if (res.containsKey('error')) {
          return emit(SendOTPFail(reason: res['error']));
        }
        emit(SendOTPSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(SendOTPFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(SendOTPFail(reason: error.toString()));
    }
  }

  /// Handles the logic for sending an OTP (One-Time Password) for pincode reset.
  ///
  /// This method is called when the `SendOTPForPincodeReset` event is dispatched.
  /// It first checks if the current state is not `SendOTPLoading`, and if so, it emits
  /// the `SendOTPLoading` state. It then calls the `sendOtpForPincodeReset` method
  /// of the `AuthRepository` to send the OTP. If the response contains an 'error' key,
  /// it emits the `SendOTPFail` state with the error reason. Otherwise, it emits the
  /// `SendOTPSuccess` state.
  ///
  /// If an error occurs during the process, it logs the error and emits the `SendOTPFail`
  /// state with the error message.
  _onSendOTPForPincodeReset(
    SendOTPForPincodeReset event,
    Emitter emit,
  ) async {
    try {
      if (state is! SendOTPLoading) {
        emit(SendOTPLoading());
        final res = await repository.sendOtpForPincodeReset(
          event.phoneNumber,
          event.countryCode,
          event.signature,
          event.accessToken,
        );
        if (res.containsKey('error')) {
          return emit(SendOTPFail(reason: res['error']));
        }
        emit(SendOTPSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(SendOTPFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(SendOTPFail(reason: error.toString()));
    }
  }

  /// Handles the logic for resetting the user's password.
  ///
  /// This method is called when the `ResetPassword` event is dispatched.
  /// It first checks if the current state is not `ResetLoading`, and if so, it emits
  /// the `ResetLoading` state. It then calls the `resetPassword` method
  /// of the `AuthRepository` to reset the password. If the response contains an 'error' key,
  /// it emits the `ResetFail` state with the error reason. Otherwise, it emits the
  /// `ResetSuccess` state.
  ///
  /// If an error occurs during the process, it logs the error and emits the `ResetFail`
  /// state with the error message.
  _onResetPassword(
    ResetPassword event,
    Emitter emit,
  ) async {
    try {
      if (state is! ResetLoading) {
        emit(ResetLoading());
        final res = await repository.resetPassword(
          phoneNumber: event.phoneNumber,
          otp: event.otp,
          countryCode: event.countryCode,
          newPassword: event.newPassword,
        );
        if (res.containsKey('error')) {
          return emit(ResetFail(reason: res['error']));
        }
        emit(ResetSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(ResetFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(ResetFail(reason: error.toString()));
    }
  }

  /// Handles the logic for resetting the user's pincode.
  ///
  /// This method is called when the `ResetPincode` event is dispatched.
  /// It first checks if the current state is not `ResetLoading`, and if so, it emits
  /// the `ResetLoading` state. It then calls the `resetPincode` method
  /// of the `AuthRepository` to reset the pincode. If the response contains an 'error' key,
  /// it emits the `ResetFail` state with the error reason. Otherwise, it emits the
  /// `ResetSuccess` state.
  ///
  /// If an error occurs during the process, it logs the error and emits the `ResetFail`
  /// state with the error message.
  _onResetPincode(
    ResetPincode event,
    Emitter emit,
  ) async {
    try {
      if (state is! ResetLoading) {
        emit(ResetLoading());
        final res = await repository.resetPincode(
          phoneNumber: event.phoneNumber,
          otp: event.otp,
          countryCode: event.countryCode,
          newPincode: event.newPincode,
        );
        if (res.containsKey('error')) {
          return emit(ResetFail(reason: res['error']));
        }
        await deleteToken();
        final data = res['successResponse'];
        await storeToken(data['jwtToken']);
        storeDisplayName('${data['firstName']} ${data['lastName']}');
        emit(ResetSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(ResetFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(ResetFail(reason: error.toString()));
    }
  }

  /// Logs in a user with the provided pincode.
  ///
  /// This method is responsible for authenticating a user with the application using a pincode. It first checks if the `LoginWithPincodeLoading` state is not already set, and if so, it emits the `LoginWithPincodeLoading` state. It then retrieves the user's country code and phone number, and calls the `AuthRepository.loginWithPincode()` method, passing the provided `pincode`, `countryCode`, and `phoneNumber` parameters.
  ///
  /// If the login is successful, it stores the returned JWT token and emits the `LoginWithPincodeSuccess` state. If an error occurs during the process, it logs the error and emits the `LoginWithPincodeFail` state with the error message.
  _onLoginWithPincode(
    LoginWithPincode event,
    Emitter emit,
  ) async {
    try {
      if (state is! LoginWithPincodeLoading) {
        emit(LoginWithPincodeLoading());
        final countryCode = await getCountryCode();
        final phoneNumber = await getPhoneNumber();
        int phoneNumberInt = int.parse(phoneNumber!);
        final res = await repository.loginWithPincode(
          pincode: event.pincode,
          countryCode: countryCode!,
          phoneNumber: phoneNumberInt,
        );
        if (res.containsKey('error')) {
          return emit(LoginWithPincodeFail(reason: res['error']));
        }
        final token = res['successResponse']['jwtToken'];

        await storeToken(token);
        emit(LoginWithPincodeSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(LoginWithPincodeFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(LoginWithPincodeFail(reason: error.toString()));
    }
  }

  _onUploadProfilePicture(UploadProfilePicture event, Emitter emit) async {
    //
  }

  /// Verifies the provided OTP (One-Time Password) for the given phone number and country code.
  ///
  /// This method is responsible for verifying the OTP entered by the user. It first checks if the `OTPVerificationLoading` state is not already set, and if so, it emits the `OTPVerificationLoading` state. It then calls the `AuthRepository.verifyOtp()` method, passing the provided `phoneNumber`, `code`, and `countryCode` parameters.
  ///
  /// If the response from `AuthRepository.verifyOtp()` contains an 'error' key, the method emits the `OTPVerificationFail` state with the error reason. If the response contains a 'response' key, the method emits the `OTPVerificationSuccess` state with the user ID. Otherwise, it emits the `OTPVerificationSuccess` state without any additional data.
  ///
  /// If an exception occurs during the process, the method emits the `OTPVerificationFail` state with the error reason.
  _onVerifyOTP(VerfiyOTP event, Emitter emit) async {
    try {
      if (state is! OTPVerificationLoading) {
        emit(OTPVerificationLoading());

        final res = await repository.verifyOtp(
          phoneNumber: event.phoneNumber,
          code: event.code,
          countryCode: event.conutryCode,
        );
        if (res.containsKey('error')) {
          return emit(OTPVerificationFail(reason: res['error']));
        }
        if (res.containsKey('response')) {
          return emit(OTPVerificationSuccess(userId: res['response']));
        }
        emit(OTPVerificationSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(OTPVerificationFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(OTPVerificationFail(reason: error.toString()));
    }
  }

  _onUpdateUser(UpdateUser event, Emitter emit) async {
    try {
      //
    } catch (error) {
      log(error.toString());
      emit(UpdateFail(reason: error.toString()));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter emit) async {
    try {
      if (state is! DeleteUserLoading) {
        emit(DeleteUserLoading());
        final token = await getToken();
        final res = await repository.deleteUser(accessToken: token ?? '');
        if (res.containsKey('error')) {
          return emit(DeleteUserFail(reason: res['error']));
        }
        emit(DeleteUserSucess());
      }
    } catch (error) {
      emit(AuthFail(reason: error.toString()));
    }
  }

  /// Logs in a user with the provided phone number and password.
  ///
  /// This method is responsible for authenticating a user with the application. It first checks if the `LoginUserLoading` state is not already set, and if so, it emits the `LoginUserLoading` state. It then calls the `AuthRepository.loginUser()` method, passing the provided `phoneNumber`, `countryCode`, and `password` parameters.
  ///
  /// If the response from `AuthRepository.loginUser()` contains an 'error' key, the method emits the `LoginUserFail` state with the error reason. Otherwise, it stores the returned JWT token, the user's display name, and phone number, and emits the `LoginUserSuccess` state.
  ///
  /// If an exception occurs during the process, the method emits the `LoginUserFail` state with the error reason.
  _onLoginUser(LoginUser event, Emitter emit) async {
    try {
      if (state is! LoginUserLoading) {
        emit(LoginUserLoading());
        final phoneNumber = int.parse(event.phoneNumber.trim());
        final res = await repository.loginUser(
          phoneNumber: phoneNumber,
          countryCode: event.countryCode,
          password: event.password,
        );
        if (res.containsKey('error')) {
          return emit(LoginUserFail(reason: res['error']));
        }
        final data = res['successResponse'];
        final token = data['jwtToken'];
        await storeToken(token);
        storeDisplayName('${data['firstName']} ${data['lastName']}');
        storePhoneNumber(event.phoneNumber);
        emit(LoginUserSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(LoginUserFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      emit(LoginUserFail(reason: error.toString()));
    }
  }

  /// Creates a new user account.
  ///
  /// This method is responsible for registering a new user with the application. It first checks if the `RegisterUserLoaing` state is not already set, and if so, it emits the `RegisterUserLoaing` state. It then calls the `AuthRepository.registerUser()` method, passing the provided `userModel` parameter.
  ///
  /// If the response from `AuthRepository.registerUser()` contains an 'error' key, the method emits the `RegisterUserFail` state with the error reason and, if available, the field name that caused the error. Otherwise, it stores the returned JWT token, the user's display name, phone number, and country code, and emits the `RegisterUserSuccess` state.
  ///
  /// If an exception occurs during the process, the method emits the `RegisterUserFail` state with the error reason.
  _onCreateAccount(CreateAccount event, Emitter emit) async {
    try {
      if (state is! RegisterUserLoaing) {
        emit(RegisterUserLoaing());
        final res = await repository.registerUser(
          event.userModel,
        );
        if (res.containsKey('error')) {
          return emit(RegisterUserFail(reason: res['error']));
        }
        final token = res['successResponse']['jwtToken'];
        await deleteToken();
        await storeToken(token);
        storeDisplayName(
          '${event.userModel.firstName} ${event.userModel.lastName}',
        );
        storePhoneNumber(event.userModel.phoneNumber!);
        setCountryCode(event.userModel.countryCode!);
        emit(RegisterUserSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(RegisterUserFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      emit(RegisterUserFail(reason: error.toString()));
    }
  }

  /// Sends an OTP (One-Time Password) to the user's phone number.
  ///
  /// This method is responsible for initiating the OTP sending process. It first checks if the `SendOTPLoading` state is not already set, and if so, it emits the `SendOTPLoading` state. It then calls the `AuthRepository.sendOtp()` method, passing the provided `phoneNumber` and `countryCode` parameters.
  ///
  /// If the response from `AuthRepository.sendOtp()` contains an 'error' key, the method emits the `SendOTPFail` state with the error reason. Otherwise, it emits the `SendOTPSuccess` state.
  ///
  /// If an exception occurs during the process, the method logs the error and emits the `SendOTPFail` state with the error reason.
  _onSendOTP(SendOTP event, Emitter emit) async {
    try {
      if (state is! SendOTPLoading) {
        emit(SendOTPLoading());

        final res = await repository.sendOtp(
          event.phoneNumber,
          event.countryCode,
          event.signature,
        );
        if (res.containsKey('error')) {
          return emit(SendOTPFail(reason: res['error'], userId: res['userId']));
        }
        emit(SendOTPSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(SendOTPFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(SendOTPFail(reason: error.toString()));
    }
  }
}
