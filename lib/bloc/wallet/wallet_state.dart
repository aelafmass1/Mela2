// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'wallet_bloc.dart';

class WalletState {
  final List<WalletModel> wallets;

  WalletState({required this.wallets});

  WalletState copyWith({
    List<WalletModel>? wallets,
  }) {
    return WalletState(
      wallets: wallets ?? this.wallets,
    );
  }
}

final class FetchWalletsLoading extends WalletState {
  FetchWalletsLoading({required super.wallets});
}

final class FetchWalletsFail extends WalletState {
  final String reason;
  FetchWalletsFail({required super.wallets, required this.reason});
}

final class FetchWalletSuccess extends WalletState {
  FetchWalletSuccess({required super.wallets});
}

final class CreateWalletLoading extends WalletState {
  CreateWalletLoading({required super.wallets});
}

final class CreateWalletFail extends WalletState {
  final String reason;
  CreateWalletFail({required super.wallets, required this.reason});
}

final class CreateWalletSuccess extends WalletState {
  CreateWalletSuccess({required super.wallets});
}

final class AddFundToWalletLoading extends WalletState {
  AddFundToWalletLoading({required super.wallets});
}

final class AddFundToWalletFail extends WalletState {
  final String reason;
  AddFundToWalletFail({required super.wallets, required this.reason});
}

final class AddFundToWalletSuccess extends WalletState {
  final WalletTransactionModel walletTransactionModel;

  AddFundToWalletSuccess({
    required super.wallets,
    required this.walletTransactionModel,
  });
}
