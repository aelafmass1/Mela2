import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/core/exceptions/server_exception.dart';
import 'package:transaction_mobile_app/data/models/bank_rate.dart';
import 'package:transaction_mobile_app/data/repository/currency_rate_repository.dart';

import '../../core/utils/settings.dart';

part 'bank_currency_rate_event.dart';
part 'bank_currency_rate_state.dart';

class BankCurrencyRateBloc
    extends Bloc<BankCurrencyRateEvent, BankCurrencyRateState> {
  BankCurrencyRateBloc() : super(BankCurrencyRateInitial()) {
    on<FetchCurrencyRate>(_onFetchCurrencyRate);
  }
  _onFetchCurrencyRate(
      FetchCurrencyRate event, Emitter<BankCurrencyRateState> emit) async {
    try {
      if (state is! BankCurrencyRateLoading) {
        emit(BankCurrencyRateLoading());

        final token = await getToken();
        final res = await CurrencyRateRepository.fetchCurrencyRate(token!);
        final rates = res.map((rate) => BankRate.fromMap(rate)).toList();
        emit(BankCurrencyRateSuccess(rates: rates));
      }
    } on ServerException catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
      log(error.toString());
      emit(BankCurrencyRateFail(reason: error.message));
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
      log(error.toString());
      emit(BankCurrencyRateFail(reason: error.toString()));
    }
  }
}
