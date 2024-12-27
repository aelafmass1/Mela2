part of 'money_transfer_bloc.dart';

sealed class MoneyTransferState {}

final class MoneyTransferInitial extends MoneyTransferState {}

final class MoneyTransferLoading extends MoneyTransferState {}

final class MoneyTransferFail extends MoneyTransferState {
  final String reason;

  MoneyTransferFail({required this.reason});
}

final class MoneyTransferSuccess extends MoneyTransferState {}

final class MoneyTransferOwnWalletSuccess extends MoneyTransferState {
  final WalletTransactionModel? walletTransactionModel;

  MoneyTransferOwnWalletSuccess({this.walletTransactionModel});
}

final class MoneyTransferUnregisteredUserSuccess extends MoneyTransferState {
  final WalletTransactionModel? walletTransactionModel;

  MoneyTransferUnregisteredUserSuccess({required this.walletTransactionModel});
}
