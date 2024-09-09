import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/data/models/bank_fee_model.dart';
import 'package:transaction_mobile_app/data/repository/banks_repository.dart';

import '../../core/utils/settings.dart';

part 'bank_fee_event.dart';
part 'bank_fee_state.dart';

class BankFeeBloc extends Bloc<BankFeeEvent, BankFeeState> {
  BankFeeBloc() : super(BankFeeInitial()) {
    on<FetchBankFee>(_onFetchBankFee);
  }
  _onFetchBankFee(FetchBankFee evene, Emitter emit) async {
    try {
      emit(BankFeeLoading());
      final token = await getToken();

      final res = await BanksRepository.fetchBankFee(token!);
      if (res.first.containsKey('error')) {
        return emit(BankFeeFail(reason: res.first['error']));
      }
      emit(
        BankFeeSuccess(
            bankFees: res.map((f) => BankFeeModel.fromMap(f)).toList()),
      );
    } catch (error) {
      log(error.toString());
      emit(BankFeeFail(reason: error.toString()));
    }
  }
}
