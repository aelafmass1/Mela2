import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/repository/auth_repository.dart';

import '../../core/exceptions/server_exception.dart';

part 'pincode_event.dart';
part 'pincode_state.dart';

class PincodeBloc extends Bloc<PincodeEvent, PincodeState> {
  final AuthRepository repository;
  PincodeBloc({required this.repository}) : super(PinInitial()) {
    on<SetPinCode>(_onSetPincode);
    on<VerifyPincode>(_onVerifyPincode);
  }
  _onVerifyPincode(VerifyPincode event, Emitter emit) async {
    try {
      if (state is! PinLoading) {
        emit(PinLoading());

        final res = await repository.verfiyPincode(
          event.pincode,
        );
        if (res.containsKey('error')) {
          return emit(PinFail(reason: res['error']));
        }
        emit(PinSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(PinFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      emit(PinFail(reason: error.toString()));
      log(error.toString());
    }
  }

  _onSetPincode(SetPinCode event, Emitter emit) async {
    try {
      if (state is! PinLoading) {
        emit(PinLoading());

        final res = await repository.setPincode(event.pincode);
        if (res.containsKey('error')) {
          return emit(PinFail(reason: res['error']));
        }
        emit(PinSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(PinFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      emit(PinFail(reason: error.toString()));
      log(error.toString());
    }
  }
}
//1000625045968