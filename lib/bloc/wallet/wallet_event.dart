part of 'wallet_bloc.dart';

sealed class WalletEvent {}

final class FetchWallets extends WalletEvent {}

final class CreateWallet extends WalletEvent {
  final String currency;

  CreateWallet({required this.currency});
}

final class AddFundToWallet extends WalletEvent {
  final num amount;
  final String paymentType;
  final String publicToken;
  final String savedPaymentId;
  final String paymentIntentId;
  final int walletId;

  AddFundToWallet(
      {required this.amount,
      required this.paymentType,
      required this.publicToken,
      required this.savedPaymentId,
      required this.paymentIntentId,
      required this.walletId});
}
