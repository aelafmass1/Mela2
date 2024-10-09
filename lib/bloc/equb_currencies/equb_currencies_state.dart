part of 'equb_currencies_bloc.dart';

sealed class EqubCurrenciesState {}

final class EqubCurrenciesInitial extends EqubCurrenciesState {}

final class EqubCurrenciesLoading extends EqubCurrenciesState {}

final class EqubCurrenciesFail extends EqubCurrenciesState {
  final String reason;

  EqubCurrenciesFail({required this.reason});
}

final class EqubCurrenciesSuccess extends EqubCurrenciesState {
  List<String> currencies;

  EqubCurrenciesSuccess({required this.currencies});
}
