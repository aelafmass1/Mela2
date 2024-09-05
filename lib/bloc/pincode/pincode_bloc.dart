import 'dart:developer';

import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pincode_event.dart';
part 'pincode_state.dart';

class PincodeBloc extends Bloc<PincodeEvent, PincodeState> {
  PincodeBloc() : super(PinInitial()) {
    on<SetPinCode>(_onSetPincode);
    on<VerifyPincode>(_onVerifyPincode);
  }
  _onVerifyPincode(VerifyPincode event, Emitter emit) async {
    try {
      emit(PinLoading());
      final userId = FirebaseAuth.instance.currentUser?.uid;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('users').doc(userId).get();
      final hashedPincode = snapshot.get('pincode');
      final isPincodeCorrect = BCrypt.checkpw(event.pincode, hashedPincode);
      if (isPincodeCorrect) {
        emit(PinSuccess());
      } else {
        emit(PinFail(reason: 'Incorrect Pincode'));
      }
    } catch (error) {
      emit(PinFail(reason: error.toString()));
      log(error.toString());
    }
  }

  _onSetPincode(SetPinCode event, Emitter emit) async {
    try {
      emit(PinLoading());
      //hashing pincode
      String salt = BCrypt.gensalt();
      String hashedPin = BCrypt.hashpw(event.pincode, salt);

      final userId = FirebaseAuth.instance.currentUser?.uid;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(userId).update({
        'pincode': hashedPin,
      });
      emit(PinSuccess());
    } catch (error) {
      emit(PinFail(reason: error.toString()));
      log(error.toString());
    }
  }
}
