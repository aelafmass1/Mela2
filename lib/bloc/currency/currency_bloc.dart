import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/data/models/curruncy_model.dart';
import 'package:transaction_mobile_app/data/repository/currency_repository.dart';

import '../../core/utils/settings.dart';

part 'currency_event.dart';
part 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  CurrencyBloc() : super(CurrencyInitial()) {
    on<FetchPromotionalCurrency>(_onFetchPromotinalCurrency);
    on<FetchAllCurrencies>(_onFetchAllCurrencies);
  }
  _onFetchAllCurrencies(FetchAllCurrencies event, Emitter emit) async {
    try {
      //loading state
      emit(CurrencyLoading());
      final token = await getToken();

      if (token != null) {
        final res = await CurrencyRepository.fetchCurrencies(token);
        if (res.first.containsKey('error')) {
          return emit(CurrencyFail(reason: res.first['error']));
        }
        emit(
          CurrencySuccess(
            currencies: res.map((c) => CurrencyModel.fromMap(c)).toList(),
          ),
        );
      }
    } catch (error) {
      emit(CurrencyFail(reason: error.toString()));
    }
  }

  _onFetchPromotinalCurrency(
      FetchPromotionalCurrency event, Emitter emit) async {
    try {
      emit(CurrencyLoading());
      final token = await getToken();

      if (token != null) {
        final res = await CurrencyRepository.fetchPromotionalCurrency(token);
        if (res.containsKey('error')) {
          return emit(CurrencyFail(reason: res['error']));
        }
        emit(
          CurrencySuccess(
            currencies: [
              CurrencyModel.fromMap(res),
            ],
          ),
        );
      }
    } catch (error) {
      emit(CurrencyFail(reason: error.toString()));
    }
  }
}
