part of 'money_request_bloc.dart';

sealed class MoneyRequestEvent {}

class MoneyRequest extends MoneyRequestEvent {
  final int requesterWalletId;
  final double amount;
  final String note;
  final int userId;

  MoneyRequest({
    required this.requesterWalletId,
    required this.amount,
    required this.note,
    required this.userId,
  });
}

class FetchMoneyRequestDetail extends MoneyRequestEvent {
  final int requestId;

  FetchMoneyRequestDetail({required this.requestId});
}

class RejectMoneyRequest extends MoneyRequestEvent {
  final int requestId;

  RejectMoneyRequest({required this.requestId});
}
