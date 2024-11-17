part of 'transfer_rate_bloc.dart';

sealed class TransferRateEvent extends Equatable {
  const TransferRateEvent();

  @override
  List<Object> get props => [];
}

class FetchTransferRate extends TransferRateEvent {
  final int fromWalletId;
  final int toWalletId;

  const FetchTransferRate({
    required this.fromWalletId,
    required this.toWalletId,
  });

  @override
  List<Object> get props => [fromWalletId, toWalletId];
}

class ResetTransferRate extends TransferRateEvent {}
