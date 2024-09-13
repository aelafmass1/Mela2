part of 'money_transfer_bloc.dart';

sealed class MoneyTransferEvent {}

final class SendMoney extends MoneyTransferEvent {
  final ReceiverInfo receiverInfo;
  final String paymentId;
  final String savedPaymentId;

  SendMoney({
    required this.receiverInfo,
    required this.paymentId,
    required this.savedPaymentId,
  });
}
