part of 'bank_currency_rate_bloc.dart';

sealed class BankCurrencyRateEvent {}

final class FetchCurrencyRate extends BankCurrencyRateEvent {}
