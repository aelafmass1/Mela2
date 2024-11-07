import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/data/repository/wallet_repository.dart';

import '../../core/utils/settings.dart';

part 'wallet_currency_event.dart';
part 'wallet_currency_state.dart';

class WalletCurrencyBloc
    extends Bloc<WalletCurrencyEvent, WalletCurrencyState> {
  final WalletRepository repository;
  WalletCurrencyBloc({required this.repository})
      : super(WalletCurrencyInitial()) {
    on<FetchWalletCurrency>(_onFetchWalletCurrency);
  }
  _onFetchWalletCurrency(FetchWalletCurrency event, Emitter emit) async {
    try {
      if (state is! FetchWalletCurrencyLoading) {
        emit(
          FetchWalletCurrencyLoading(),
        );
        final accessToken = await getToken();
        final res = await repository.fetchWalletCurrencies(
          accessToken: accessToken ?? '',
        );
        if (res.containsKey('error')) {
          return emit(
            FetchWalletCurrencyFail(reason: res['error']),
          );
        }
        final currencies = (res['data'] as List).map((c) => c['code']).toList();

        emit(
          FetchWalletCurrencySuccess(
            currencies: currencies,
          ),
        );
      }
    } catch (error) {
      emit(
        FetchWalletCurrencyFail(
          reason: error.toString(),
        ),
      );
    }
  }
}
