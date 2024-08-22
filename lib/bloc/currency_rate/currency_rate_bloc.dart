import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/data/models/bank_rate.dart';
import 'package:transaction_mobile_app/data/repository/currency_rate_repository.dart';

part 'currency_rate_event.dart';
part 'currency_rate_state.dart';

class CurrencyRateBloc extends Bloc<CurrencyRateEvent, CurrencyRateState> {
  CurrencyRateBloc() : super(CurrencyRateInitial()) {
    on<FetchCurrencyRate>(_onFetchCurrencyRate);
  }
  _onFetchCurrencyRate(
      FetchCurrencyRate event, Emitter<CurrencyRateState> emit) async {
    try {
      final auth = FirebaseAuth.instance;
      final token = await auth.currentUser?.getIdToken();
      if (token != null) {
        emit(CurrencyRateLoading());
        final res = await CurrencyRateRepository.fetchCurrencyRate(token);
        final rates = res.map((rate) => BankRate.fromMap(rate)).toList();
        emit(CurrencyRateSuccess(rates: rates));
      }
    } catch (error) {
      log(error.toString());
      emit(CurrencyRateFail(reason: error.toString()));
    }
  }
}
