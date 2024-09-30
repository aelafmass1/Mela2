import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/models/bank_model.dart';
import 'package:transaction_mobile_app/data/repository/banks_repository.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/settings.dart';

part 'banks_event.dart';
part 'banks_state.dart';

class BanksBloc extends Bloc<BanksEvent, BanksState> {
  BanksBloc() : super(BanksInitial()) {
    on<FetchBanks>(_onFetchBanks);
  }

  _onFetchBanks(FetchBanks event, Emitter emit) async {
    try {
      if (state is! BanksLoading) {
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
      }
    } on ServerException catch (error, stackTrace) {
      emit(BanksFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
      log(error.toString());
      emit(BanksFail(reason: error.toString()));
    }
  }
}
