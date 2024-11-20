import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/models/wallet_model.dart';
import 'package:transaction_mobile_app/data/repository/wallet_repository.dart';

part 'wallet_recent_transaction_event.dart';
part 'wallet_recent_transaction_state.dart';

class WalletRecentTransactionBloc
    extends Bloc<WalletRecentTransactionEvent, WalletRecentTransactionState> {
  final WalletRepository repository;
  WalletRecentTransactionBloc({required this.repository})
      : super(WalletRecentTransactionInitial()) {
    on<FetchRecentTransaction>(_onFetchRecentTransaction);
  }

  _onFetchRecentTransaction(FetchRecentTransaction event, Emitter emit) async {
    try {
      if (state is! WalletRecentTransactionLoading) {
        emit(WalletRecentTransactionLoading());
        final accessToken = await getToken();
        final res = await repository.fetchRecentWalletTransactions(
          accessToken: accessToken ?? '',
        );
        if (res.containsKey('error')) {
          return emit(WalletRecentTransactionFail(reason: res['error']));
        }
        final transactions = (res['data']['successResponse'] as List)
            .map((t) => WalletModel.fromMap(t))
            .toList();
        emit(WalletRecentTransactionSuccess(
          transactions: transactions,
        ));
      }
    } catch (error) {
      log(error.toString());
      emit(WalletRecentTransactionFail(reason: error.toString()));
    }
  }
}
