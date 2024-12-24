import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/models/wallet_transaction_model.dart';
import 'package:transaction_mobile_app/data/repository/wallet_repository.dart';

part 'wallet_transaction_event.dart';
part 'wallet_transaction_state.dart';

class WalletTransactionBloc
    extends Bloc<WalletTransactionEvent, WalletTransactionState> {
  final WalletRepository repository;
  WalletTransactionBloc({required this.repository})
      : super(WalletTransactionInitial()) {
    on<FetchWalletTransaction>(_onFetchWalletTransaction);
    on<ResetWalletTransaction>(_onResetWalletTransaction);
  }
  _onResetWalletTransaction(ResetWalletTransaction event, Emitter emit) {
    emit(WalletTransactionInitial());
  }

  _onFetchWalletTransaction(FetchWalletTransaction event, Emitter emit) async {
    try {
      if (state is! WalletTransactionLoading) {
        emit(WalletTransactionLoading());
        final accessToken = await getToken();
        final res = await repository.fetchWalletTransaction(
          accessToken: accessToken ?? '',
        );
        if (res.containsKey('error')) {
          return emit(
            WalletTransactionFail(reason: res['error']),
          );
        }
        Map<String, List<WalletTransactionModel>> groupedTransactions = {};
        final walletTransactions = (res['data']['successResponse'] as List)
            .map((w) => WalletTransactionModel.fromMap(w))
            .toList();

        for (var transaction in walletTransactions) {
          String formattedDate =
              DateFormat('yyyy-MM-dd').format(transaction.timestamp);

          if (groupedTransactions.containsKey(formattedDate)) {
            groupedTransactions[formattedDate]!.add(transaction);
          } else {
            groupedTransactions[formattedDate] = [transaction];
          }
        }
        emit(
          WalletTransactionSuccess(
            walletTransactions: groupedTransactions,
          ),
        );
      }
    } catch (error) {
      emit(WalletTransactionFail(reason: error.toString()));
    }
  }
}
