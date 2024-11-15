part of 'wallet_transaction_bloc.dart';

sealed class WalletTransactionState {}

final class WalletTransactionInitial extends WalletTransactionState {}

final class WalletTransactionLoading extends WalletTransactionState {}

final class WalletTransactionFail extends WalletTransactionState {
  final String reason;

  WalletTransactionFail({required this.reason});
}

final class WalletTransactionSuccess extends WalletTransactionState {
  Map<String, List<WalletTransactionDetailModel>> walletTransactions;

  WalletTransactionSuccess({required this.walletTransactions});
}
