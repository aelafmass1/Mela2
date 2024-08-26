part of 'currency_bloc.dart';

sealed class CurrencyEvent {}

final class FetchPromotionalCurrency extends CurrencyEvent {}

final class FetchAllCurrencies extends CurrencyEvent {}
