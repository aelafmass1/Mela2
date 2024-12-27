part of 'bank_currency_rate_bloc.dart';

@immutable
sealed class BankCurrencyRateState {}

final class BankCurrencyRateInitial extends BankCurrencyRateState {}

final class BankCurrencyRateLoading extends BankCurrencyRateState {}

final class BankCurrencyRateSuccess extends BankCurrencyRateState {
  final List<BankRate> rates;

  BankCurrencyRateSuccess({required this.rates});
}

final class BankCurrencyRateFail extends BankCurrencyRateState {
  final String reason;

  BankCurrencyRateFail({required this.reason});
}
