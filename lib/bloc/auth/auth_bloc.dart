import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<SendOTP>(_onSendOTP);
    on<CreateAccount>(_onCreateAccount);
    on<LoginUser>(_onLoginUser);
  }
  _onLoginUser(LoginUser event, Emitter emit) async {
    try {
      emit(AuthLoading());
      await _auth.signInWithEmailAndPassword(
        email: '${event.phoneNumber.trim()}@phone.firebase',
        password: event.password.trim(),
      );
      emit(AuthSucces());
    } catch (error) {
      emit(AuthFail(reason: error.toString()));
    }
  }

  _onCreateAccount(CreateAccount event, Emitter emit) async {
    try {
      emit(AuthLoading());
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: '${event.userModel.phoneNumber}@phone.firebase',
        password: event.userModel.password!,
      );
      if (userCredential.credential?.accessToken != null) {
        FirebaseFirestore _firestore = FirebaseFirestore.instance;
        await _firestore.collection('users').doc(userCredential.user?.uid).set(
              event.userModel.toMap(),
            );
      }
      emit(AuthSucces());
    } catch (error) {
      emit(AuthFail(reason: error.toString()));
    }
  }

  _onSendOTP(SendOTP event, Emitter emit) async {
    String errorMessge = '';
    emit(AuthLoading());
    _auth
        .verifyPhoneNumber(
      phoneNumber: event.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        log('auth success');
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          errorMessge = 'The provided phone number is not valid.';
          ;
        } else {
          log('Failed to verify phone number: ${e.message}');
          errorMessge = 'Failed to verify phone number';
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        log('OTP has been sent.');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        errorMessge = 'Time out';
        // Handle timeout (optional)
      },
      timeout: const Duration(seconds: 60), // Optional timeout duration
    )
        .then((value) {
      if (errorMessge.isNotEmpty) {
        return emit(AuthFail(reason: errorMessge));
      }
      emit(AuthSucces());
    });
  }
}
