part of 'reject_money_request_bloc.dart';

sealed class RejectMoneyRequestState {}

final class RejectMoneyRequestInitial extends RejectMoneyRequestState {}

final class RejectMoneyRequestLoading extends RejectMoneyRequestState {}

final class RejectMoneyRequestFail extends RejectMoneyRequestState {
  final String reason;

  RejectMoneyRequestFail({required this.reason});
}

final class RejectMoneyRequestSuccess extends RejectMoneyRequestState {}
