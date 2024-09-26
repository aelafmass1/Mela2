import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';

import '../../data/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SendOTP>(_onSendOTP);
    on<CreateAccount>(_onCreateAccount);
    on<LoginUser>(_onLoginUser);
    on<DeleteUser>(_onDeleteUser);
    on<UpdateUser>(_onUpdateUser);
    on<VerfiyOTP>(_onVerifyOTP);
    on<UploadProfilePicture>(_onUploadProfilePicture);
    on<LoginWithPincode>(_onLoginWithPincode);
  }

  _onLoginWithPincode(LoginWithPincode event, Emitter emit) async {
    try {
      if (state is! LoginWithPincodeLoading) {
        emit(LoginWithPincodeLoading());
        final countryCode = await getCountryCode();
        final phoneNumber = await getPhoneNumber();
        int phoneNumberInt = int.parse(phoneNumber!);
        final res = await AuthRepository.loginWithPincode(
          pincode: event.pincode,
          countryCode: countryCode!,
          phoneNumber: phoneNumberInt,
        );
        if (res.containsKey('error')) {
          return emit(LoginWithPincodeFail(reason: res['error']));
        }
        final token = res['successResponse']['jwtToken'];
        storeToken(token);
        emit(LoginWithPincodeSuccess());
      }
    } catch (error) {
      log(error.toString());
      emit(LoginWithPincodeFail(reason: error.toString()));
    }
  }

  _onUploadProfilePicture(UploadProfilePicture event, Emitter emit) async {
    //
  }

  _onVerifyOTP(VerfiyOTP event, Emitter emit) async {
    try {
      if (state is! OTPVerificationLoading) {
        // emit(OTPVerificationLoading());

        // final res = await AuthRepository.verifyOtp(
        //   phoneNumber: event.phoneNumber,
        //   code: event.code,
        //   countryCode: event.conutryCode,
        // );
        // if (res.containsKey('error')) {
        //   return emit(OTPVerificationFail(reason: res['error']));
        // }
        // if (res.containsKey('response')) {
        //   return emit(OTPVerificationSuccess(userId: res['response']));
        // }
        emit(OTPVerificationSuccess());
      }
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
      //
    } catch (error) {
      emit(AuthFail(reason: error.toString()));
    }
  }

  _onLoginUser(LoginUser event, Emitter emit) async {
    try {
      if (state is! LoginUserLoading) {
        emit(LoginUserLoading());
        final phoneNumber = int.parse(event.phoneNumber.trim());
        final res = await AuthRepository.loginUser(
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
    } catch (error) {
      emit(LoginUserFail(reason: error.toString()));
    }
  }

  _onCreateAccount(CreateAccount event, Emitter emit) async {
    try {
      if (state is! RegisterUserLoaing) {
        emit(RegisterUserLoaing());
        final res = await AuthRepository.registerUser(
          event.userModel,
        );
        if (res.containsKey('error')) {
          if (res['error'] is String) {
            return emit(RegisterUserFail(reason: res['error']));
          } else {
            List errorResponse = res['data']['errorResponse'];
            String fieldName = '';
            if (errorResponse.isNotEmpty) {
              if (errorResponse.first.containsKey('field')) {
                fieldName = errorResponse.first['field'];
              }
            }
            return emit(RegisterUserFail(
              reason: res['error'],
              field: fieldName,
            ));
          }
        }
        final token = res['successResponse']['jwtToken'];
        storeToken(token);
        storeDisplayName(
            '${event.userModel.firstName} ${event.userModel.lastName}');
        storePhoneNumber(event.userModel.phoneNumber!);
        setCountryCode(event.userModel.countryCode!);
        emit(RegisterUserSuccess());
      }
    } catch (error) {
      emit(RegisterUserFail(reason: error.toString()));
    }
  }

  _onSendOTP(SendOTP event, Emitter emit) async {
    try {
      if (state is! SendOTPLoading) {
        // emit(SendOTPLoading());

        // final res = await AuthRepository.sendOtp(
        //   event.phoneNumber,
        //   event.countryCode,
        // );
        // if (res.containsKey('error')) {
        //   return emit(SendOTPFail(reason: res['error']));
        // }
        emit(SendOTPSuccess());
      }
    } catch (error) {
      log(error.toString());
      emit(SendOTPFail(reason: error.toString()));
    }
  }
}
