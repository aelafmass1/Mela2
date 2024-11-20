part of 'wallet_recent_transaction_bloc.dart';

sealed class WalletRecentTransactionEvent extends Equatable {
  const WalletRecentTransactionEvent();

  @override
  List<Object> get props => [];
}

final class FetchRecentTransaction extends WalletRecentTransactionEvent {}
