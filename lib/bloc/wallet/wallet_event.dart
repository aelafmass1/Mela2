part of 'wallet_bloc.dart';

sealed class WalletEvent {}

final class FetchWallets extends WalletEvent {}

final class CreateWallet extends WalletEvent {
  final String currency;

  CreateWallet({required this.currency});
}
