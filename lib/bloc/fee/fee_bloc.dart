import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/data/models/fee_models.dart';
import 'package:transaction_mobile_app/data/repository/fee_repository.dart';

part 'fee_event.dart';
part 'fee_state.dart';

class FeeBloc extends Bloc<FeeEvent, FeeState> {
  FeeBloc() : super(FeeInitial()) {
    on<FetchFees>(_onFetchFees);
  }
  _onFetchFees(FetchFees event, Emitter emit) async {
    try {
      emit(FeeLoading());
      final accessToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final res = await FeeRepository.fetchFees(accessToken!);
      if (res.first.containsKey('error')) {
        return emit(FeeFailed(reason: res.first['error']));
      }
      emit(
        FeeSuccess(
          fees: res.map((f) => FeeModel.fromMap(f)).toList(),
        ),
      );
    } catch (error) {
      log(error.toString());
      emit(FeeFailed(reason: error.toString()));
    }
  }
}
