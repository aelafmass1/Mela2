part of 'wallet_transaction_bloc.dart';

sealed class WalletTransactionEvent extends Equatable {
  const WalletTransactionEvent();

  @override
  List<Object> get props => [];
}

final class FetchWalletTransaction extends WalletTransactionEvent {}

final class ResetWalletTransaction extends WalletTransactionEvent {}
