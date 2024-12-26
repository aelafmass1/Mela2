part of 'currency_bloc.dart';

@immutable
sealed class CurrencyState {}

final class CurrencyInitial extends CurrencyState {}

final class CurrencyLoading extends CurrencyState {}

final class CurrencySuccess extends CurrencyState {
  final List<CurrencyModel> currencies;

  CurrencySuccess({required this.currencies});
}

final class CurrencyFail extends CurrencyState {
  final String reason;

  CurrencyFail({required this.reason});
}
