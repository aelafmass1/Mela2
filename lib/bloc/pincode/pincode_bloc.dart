import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/repository/auth_repository.dart';

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
      final token = await getToken();

      final res = await AuthRepository.verfiyPincode(
        token ?? '',
        event.pincode,
      );
      if (res.containsKey('error')) {
        return emit(PinFail(reason: res['error']));
      }
      emit(PinSuccess());
    } catch (error) {
      emit(PinFail(reason: error.toString()));
      log(error.toString());
    }
  }

  _onSetPincode(SetPinCode event, Emitter emit) async {
    try {
      emit(PinLoading());
      final token = await getToken();
      final res = await AuthRepository.setPincode(token ?? '', event.pincode);
      if (res.containsKey('error')) {
        return emit(PinFail(reason: res['error']));
      }
      emit(PinSuccess());
    } catch (error) {
      emit(PinFail(reason: error.toString()));
      log(error.toString());
    }
  }
}
//1000625045968