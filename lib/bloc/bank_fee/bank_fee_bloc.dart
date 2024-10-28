import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';
import 'package:transaction_mobile_app/core/utils/process_exception.dart';
import 'package:transaction_mobile_app/data/models/bank_fee_model.dart';
import 'package:transaction_mobile_app/data/repository/banks_repository.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/settings.dart';

part 'bank_fee_event.dart';
part 'bank_fee_state.dart';

class BankFeeBloc extends Bloc<BankFeeEvent, BankFeeState> {
  final BanksRepository repository;
  BankFeeBloc({required this.repository}) : super(BankFeeInitial()) {
    on<FetchBankFee>(_onFetchBankFee);
  }
  _onFetchBankFee(FetchBankFee evene, Emitter emit) async {
    try {
      if (state is! BankFeeLoading) {
        emit(BankFeeLoading());
        final token = await getToken();

        final res = await repository.fetchBankFee(token!);
        if (res.first.containsKey('error')) {
          return emit(BankFeeFail(reason: res.first['error']));
        }
        emit(
          BankFeeSuccess(
              bankFees: res.map((f) => BankFeeModel.fromMap(f)).toList()),
        );
      }
    } on ServerException catch (error, stackTrace) {
      emit(BankFeeFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(BankFeeFail(reason: processException(error)));
    }
  }
}
