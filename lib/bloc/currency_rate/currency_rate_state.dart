part of 'currency_rate_bloc.dart';

sealed class CurrencyRateState {}

final class CurrencyRateInitial extends CurrencyRateState {}

final class CurrencyRateLoading extends CurrencyRateState {}

final class CurrencyRateSuccess extends CurrencyRateState {
  final List<BankRate> rates;

  CurrencyRateSuccess({required this.rates});
}

final class CurrencyRateFail extends CurrencyRateState {
  final String reason;

  CurrencyRateFail({required this.reason});
}
