import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/data/models/bank_model.dart';
import 'package:transaction_mobile_app/data/repository/banks_repository.dart';

import '../../core/utils/settings.dart';

part 'banks_event.dart';
part 'banks_state.dart';

class BanksBloc extends Bloc<BanksEvent, BanksState> {
  BanksBloc() : super(BanksInitial()) {
    on<FetchBanks>(_onFetchBanks);
  }

  _onFetchBanks(FetchBanks event, Emitter emit) async {
    try {
      emit(BanksLoading());
      final token = await getToken();

      final res = await BanksRepository.fetchBanks(token!);
      if (res.first.containsKey('error')) {
        return emit(BanksFail(reason: res.first['error']));
      }
      final banks = res.map((b) => BankModel.fromMap(b)).toList();
      emit(
        BanksSuccess(bankList: banks),
      );
    } catch (error) {
      log(error.toString());
      emit(BanksFail(reason: error.toString()));
    }
  }
}
