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
  final int walletId;
  final String bankLastDigits;

  AddFundToWallet(
      {required this.amount,
      required this.paymentType,
      required this.publicToken,
      required this.savedPaymentId,
      required this.walletId,
      this.bankLastDigits = ""});
}
