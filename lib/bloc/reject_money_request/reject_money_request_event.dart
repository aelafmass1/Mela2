part of 'reject_money_request_bloc.dart';

sealed class RejectMoneyReuestEvent {}

class RejectMoneyRequest extends RejectMoneyReuestEvent {
  final int requestId;

  RejectMoneyRequest({required this.requestId});
}
