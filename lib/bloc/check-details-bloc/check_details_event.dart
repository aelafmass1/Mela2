part of 'check_details_bloc.dart';

sealed class CheckDetailsEvent extends Equatable {
  const CheckDetailsEvent();

  @override
  List<Object> get props => [];
}

class FetchTransferFeesEvent extends CheckDetailsEvent {
  final int fromWalletId;
  final int toWalletId;

  const FetchTransferFeesEvent({
    required this.fromWalletId,
    required this.toWalletId,
  });
  @override
  List<Object> get props => [fromWalletId, toWalletId];
}

class ResetTransferFee extends CheckDetailsEvent {}

class FetchTransferFeeFromCurrencies extends CheckDetailsEvent {
  final String fromCurrency;
  final String toCurrency;

  const FetchTransferFeeFromCurrencies({
    required this.fromCurrency,
    required this.toCurrency,
  });
}
