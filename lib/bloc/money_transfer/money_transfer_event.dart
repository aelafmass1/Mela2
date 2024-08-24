part of 'money_transfer_bloc.dart';

sealed class MoneyTransferEvent {}

final class SendMoney extends MoneyTransferEvent {
  final ReceiverInfo receiverInfo;

  SendMoney({required this.receiverInfo});
}
