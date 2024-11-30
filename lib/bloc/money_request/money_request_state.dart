part of 'money_request_bloc.dart';

sealed class MoneyRequestState extends Equatable {
  const MoneyRequestState();

  @override
  List<Object> get props => [];
}

final class MoneyRequestInitial extends MoneyRequestState {}

final class MoneyRequestLoading extends MoneyRequestState {}

final class MoneyRequestSuccess extends MoneyRequestState {
  final int id;

  const MoneyRequestSuccess({required this.id});
}

final class MoneyRequestFailure extends MoneyRequestState {
  final String reason;

  const MoneyRequestFailure({required this.reason});
}

final class FetchMoneyRequestLoading extends MoneyRequestState {}

final class FetchMoneyRequestFail extends MoneyRequestState {
  final String reason;

  const FetchMoneyRequestFail({required this.reason});
}

final class FetchMoneyRequestSuccess extends MoneyRequestState {
  final MoneyRequestModel moneyRequestModel;

  const FetchMoneyRequestSuccess({required this.moneyRequestModel});
}

final class RejectMoneyRequestLoading extends MoneyRequestState {}

final class RejectMoneyRequestFail extends MoneyRequestState {
  final String reason;

  const RejectMoneyRequestFail({required this.reason});
}

final class RejectMoneyRequestSuccess extends MoneyRequestState {}
