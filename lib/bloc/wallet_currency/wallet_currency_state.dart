part of 'wallet_currency_bloc.dart';

sealed class WalletCurrencyState {}

final class WalletCurrencyInitial extends WalletCurrencyState {}

final class FetchWalletCurrencyLoading extends WalletCurrencyState {}

final class FetchWalletCurrencyFail extends WalletCurrencyState {
  final String reason;
  FetchWalletCurrencyFail({required this.reason});
}

final class FetchWalletCurrencySuccess extends WalletCurrencyState {
  final List currencies;
  FetchWalletCurrencySuccess({required this.currencies});
}
