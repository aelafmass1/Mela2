import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
    on<DeleteUser>(_onDeleteUser);
    on<UpdateUser>(_onUpdateUser);
  }
  _onUpdateUser(UpdateUser event, Emitter emit) async {
    try {
      emit(UpdateLoading());
      final auth = FirebaseAuth.instance;
      await auth.currentUser?.updateDisplayName(event.fullName);
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(auth.currentUser?.uid).update({
        'email': event.email,
      });
      emit(UpdateSuccess());
      //
    } catch (error) {
      log(error.toString());
      emit(UpdateFail(reason: error.toString()));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter emit) async {
    try {
      emit(AuthLoading());

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Delete the user's document from Firestore
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(currentUser.uid).delete();

        // Check if the user has a profile picture and delete it from Firebase Storage
        if (currentUser.photoURL != null) {
          final storageRef = FirebaseStorage.instance.ref();
          final phoneNumber = currentUser.email!.split('@').first;
          final imagesRef = storageRef.child('profilePictures/$phoneNumber');
          await imagesRef.delete();
        }

        // Delete the user from Firebase Authentication
        await _auth.currentUser?.reload();
        await currentUser.delete();

        emit(AuthSuccess());
      } else {
        emit(AuthFail(reason: "No user is currently signed in."));
      }
    } catch (error) {
      emit(AuthFail(reason: error.toString()));
    }
  }

  _onLoginUser(LoginUser event, Emitter emit) async {
    try {
      emit(AuthLoading());
      await _auth.signInWithEmailAndPassword(
        email: '${event.phoneNumber.trim()}@phone.firebase',
        password: event.password.trim(),
      );
      emit(AuthSuccess());
    } catch (error) {
      emit(AuthFail(reason: error.toString()));
    }
  }

  _onCreateAccount(CreateAccount event, Emitter emit) async {
    try {
      emit(AuthLoading());
      if (event.profilePicture == null) {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: '${event.userModel.phoneNumber}@phone.firebase',
          password: event.userModel.password!,
        );
        await _auth.currentUser?.updateDisplayName(
          '${event.userModel.firstName} ${event.userModel.lastName}',
        );

        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(userCredential.user?.uid).set(
              event.userModel.toMap(),
            );

        emit(AuthSuccess());
      } else {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: '${event.userModel.phoneNumber}@phone.firebase',
          password: event.userModel.password!,
        );
        await _auth.currentUser?.updateDisplayName(
          '${event.userModel.firstName} ${event.userModel.lastName}',
        );

        // upload user information
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(userCredential.user?.uid).set(
              event.userModel.toMap(),
            );

        // upload user profile picutre
        final storageRef = FirebaseStorage.instance.ref();
        final imagesRef =
            storageRef.child('profilePictures/${event.userModel.phoneNumber}');
        await imagesRef.putFile(File(event.profilePicture!.path));
        final downloadUrl = await imagesRef.getDownloadURL();

        await _auth.currentUser!.updatePhotoURL(downloadUrl);
        emit(AuthSuccess());
      }
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
      emit(AuthSuccess());
    });
  }
}
