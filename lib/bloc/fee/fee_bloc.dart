import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/data/models/fee_models.dart';
import 'package:transaction_mobile_app/data/repository/fee_repository.dart';

import '../../core/utils/settings.dart';

part 'fee_event.dart';
part 'fee_state.dart';

class FeeBloc extends Bloc<FeeEvent, FeeState> {
  FeeBloc() : super(FeeInitial()) {
    on<FetchFees>(_onFetchFees);
  }
  _onFetchFees(FetchFees event, Emitter emit) async {
    try {
      if (state is! FeeLoading) {
        emit(FeeLoading());
        final token = await getToken();

        final res = await FeeRepository.fetchFees(token!);
        if (res.first.containsKey('error')) {
          return emit(FeeFailed(reason: res.first['error']));
        }
        emit(
          FeeSuccess(
            fees: res.map((f) => FeeModel.fromMap(f)).toList(),
          ),
        );
      }
    } catch (error) {
      log(error.toString());
      emit(FeeFailed(reason: error.toString()));
    }
  }
}
