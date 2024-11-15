part of 'transfer_rate_bloc.dart';

sealed class TransferRateState extends Equatable {
  const TransferRateState();

  @override
  List<Object> get props => [];
}

final class TransferRateInitial extends TransferRateState {}

final class TransferRateLoading extends TransferRateState {}

final class TransferRateSuccess extends TransferRateState {
  final TransferRateModel transferRate;

  const TransferRateSuccess(this.transferRate);

  @override
  List<Object> get props => [transferRate];
}

final class TransferRateFailure extends TransferRateState {
  final String message;

  const TransferRateFailure(this.message);

  @override
  List<Object> get props => [message];
}
