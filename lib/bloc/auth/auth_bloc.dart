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
    // try {
    //   emit(UploadProfileLoading());
    //   // upload user profile picutre
    //   final storageRef = FirebaseStorage.instance.ref();
    //   final imagesRef =
    //       storageRef.child('profilePictures/${event.phoneNumber}');
    //   await imagesRef.putFile(File(event.profilePicture.path));
    //   final downloadUrl = await imagesRef.getDownloadURL();

    //   // await _auth.currentUser!.updatePhotoURL(downloadUrl);
    //   emit(UploadProfileSuccess());
    // } catch (error) {
    //   log(error.toString());
    //   emit(UploadProfileFail(reason: error.toString()));
    // }
  }

  _onVerifyOTP(VerfiyOTP event, Emitter emit) async {
    try {
      if (state is! OTPVerificationLoading) {
        emit(OTPVerificationLoading());
        final accessToken = await getToken();

        final res = await AuthRepository.verifyOtp(
          accessToken: accessToken!,
          phoneNumber: event.phoneNumber,
          code: event.code,
          countryCode: event.conutryCode,
        );
        if (res.containsKey('error')) {
          return emit(OTPVerificationFail(reason: res['error']));
        }
        emit(OTPVerificationSuccess());
      }
    } catch (error) {
      log(error.toString());
      emit(OTPVerificationFail(reason: error.toString()));
    }
  }

  _onUpdateUser(UpdateUser event, Emitter emit) async {
    try {
      // emit(UpdateLoading());
      // final auth = FirebaseAuth.instance;
      // await auth.currentUser?.updateDisplayName(event.fullName);
      // FirebaseFirestore firestore = FirebaseFirestore.instance;
      // await firestore.collection('users').doc(auth.currentUser?.uid).update({
      //   'email': event.email,
      // });
      // emit(UpdateSuccess());
      //
    } catch (error) {
      log(error.toString());
      emit(UpdateFail(reason: error.toString()));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter emit) async {
    try {
      // emit(AuthLoading());

      // final currentUser = _auth.currentUser;
      // if (currentUser != null) {
      //   // Delete the user's document from Firestore
      //   FirebaseFirestore firestore = FirebaseFirestore.instance;
      //   await firestore.collection('users').doc(currentUser.uid).delete();

      //   // Check if the user has a profile picture and delete it from Firebase Storage
      //   if (currentUser.photoURL != null) {
      //     final storageRef = FirebaseStorage.instance.ref();
      //     final phoneNumber = currentUser.email!.split('@').first;
      //     final imagesRef = storageRef.child('profilePictures/$phoneNumber');
      //     await imagesRef.delete();
      //   }

      //   // Delete the user from Firebase Authentication
      //   await _auth.currentUser?.reload();
      //   await currentUser.delete();

      //   emit(AuthSuccess());
      // } else {
      //   emit(AuthFail(reason: "No user is currently signed in."));
      // }
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
        emit(SendOTPLoading());
        final accessToken = await getToken();

        final res = await AuthRepository.sendOtp(
          accessToken!,
          event.phoneNumber,
          event.countryCode,
        );
        if (res.containsKey('error')) {
          return emit(SendOTPFail(reason: res['error']));
        }
        emit(SendOTPSuccess());
      }
    } catch (error) {
      log(error.toString());
      emit(SendOTPFail(reason: error.toString()));
    }
  }
}
