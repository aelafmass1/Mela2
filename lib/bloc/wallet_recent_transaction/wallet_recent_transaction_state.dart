part of 'wallet_recent_transaction_bloc.dart';

sealed class WalletRecentTransactionState {}

final class WalletRecentTransactionInitial
    extends WalletRecentTransactionState {}

final class WalletRecentTransactionLoading
    extends WalletRecentTransactionState {}

final class WalletRecentTransactionFail extends WalletRecentTransactionState {
  final String reason;

  WalletRecentTransactionFail({required this.reason});
}

final class WalletRecentTransactionSuccess
    extends WalletRecentTransactionState {
  final List<WalletModel> transactions;

  WalletRecentTransactionSuccess({required this.transactions});
}
