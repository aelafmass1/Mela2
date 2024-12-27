part of 'fee_bloc.dart';

sealed class FeeState {}

final class FeeInitial extends FeeState {}

final class FeeLoading extends FeeState {}

final class FeeFailed extends FeeState {
  final String reason;

  FeeFailed({required this.reason});
}

final class FeeSuccess extends FeeState {
  final List<FeeModel> fees;

  FeeSuccess({required this.fees});
}

final class RemittanceExchangeRateLoading extends FeeState {}

final class RemittanceExchangeRateFailed extends FeeState {
  final String reason;

  RemittanceExchangeRateFailed({required this.reason});
}

final class RemittanceExchangeRateSuccess extends FeeState {
  final List<RemittanceExchangeRateModel> walletCurrencies;

  RemittanceExchangeRateSuccess({required this.walletCurrencies});
}
