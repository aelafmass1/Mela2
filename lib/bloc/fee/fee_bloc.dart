import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/models/fee_models.dart';
import 'package:transaction_mobile_app/data/models/remittance_exchange_rate_model.dart';
import 'package:transaction_mobile_app/data/repository/fee_repository.dart';

part 'fee_event.dart';
part 'fee_state.dart';

class FeeBloc extends Bloc<FeeEvent, FeeState> {
  final FeeRepository feeRepository;
  FeeBloc({required this.feeRepository}) : super(FeeInitial()) {
    on<FetchRemittanceExchangeRate>(_onFetchRemittanceExchangeRate);
  }

  _onFetchRemittanceExchangeRate(
      FetchRemittanceExchangeRate event, Emitter emit) async {
    try {
      emit(RemittanceExchangeRateLoading());
      final token = await getToken();
      final res = await feeRepository.fetchRemittanceExchangeRate(token ?? '');
      if (res.isEmpty) {
        return emit(
          RemittanceExchangeRateFailed(
            reason: 'No exchange rate found',
          ),
        );
      }
      if (res.first.containsKey("error")) {
        return emit(
          RemittanceExchangeRateFailed(
            reason: res.first['error'],
          ),
        );
      }
      final rates =
          res.map((c) => RemittanceExchangeRateModel.fromMap(c)).toList();
      emit(
        RemittanceExchangeRateSuccess(
          walletCurrencies: rates,
        ),
      );
    } catch (error) {
      emit(
        RemittanceExchangeRateFailed(
          reason: error.toString(),
        ),
      );
    }
  }
}
