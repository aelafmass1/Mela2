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

final class TransferToOwnWallet extends MoneyTransferEvent {
  final int fromWalletId;
  final int toWalletId;
  final double amount;
  final String note;

  TransferToOwnWallet({
    required this.fromWalletId,
    required this.toWalletId,
    required this.amount,
    required this.note,
  });
}

final class TransferToUnregisteredUser extends MoneyTransferEvent {
  final String phoneNumber;
  final double amount;
  final int senderWalletId;

  TransferToUnregisteredUser(
      {required this.phoneNumber,
      required this.amount,
      required this.senderWalletId});
}
