part of 'transaction_bloc.dart';

sealed class TransactionState {}

final class TransactionInitial extends TransactionState {}

final class TransactionLoading extends TransactionState {}

final class TransactionSuccess extends TransactionState {
  final Map<String, List<ReceiverInfo>> data;

  TransactionSuccess({required this.data});
}

final class TransactionFail extends TransactionState {
  final String reason;

  TransactionFail({required this.reason});
}
