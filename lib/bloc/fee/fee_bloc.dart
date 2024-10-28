import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/models/fee_models.dart';
import 'package:transaction_mobile_app/data/repository/fee_repository.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/process_exception.dart';
import '../../core/utils/settings.dart';

part 'fee_event.dart';
part 'fee_state.dart';

class FeeBloc extends Bloc<FeeEvent, FeeState> {
  final FeeRepository feeRepository;
  FeeBloc({required this.feeRepository}) : super(FeeInitial()) {
    on<FetchFees>(_onFetchFees);
  }
  _onFetchFees(FetchFees event, Emitter emit) async {
    try {
      if (state is! FeeLoading) {
        emit(FeeLoading());
        final token = await getToken();

        final res = await feeRepository.fetchFees(token!);
        if (res.first.containsKey('error')) {
          return emit(FeeFailed(reason: res.first['error']));
        }
        emit(
          FeeSuccess(
            fees: res.map((f) => FeeModel.fromMap(f)).toList(),
          ),
        );
      }
    } on ServerException catch (error, stackTrace) {
      emit(FeeFailed(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(FeeFailed(reason: processException(error)));
    }
  }
}
