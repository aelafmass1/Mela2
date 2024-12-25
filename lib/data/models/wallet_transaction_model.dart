import 'package:transaction_mobile_app/data/models/contact_status_model.dart';
import 'package:transaction_mobile_app/data/models/wallet_model.dart';

class WalletTransactionModel {
  final int? transactionId;
  final num? amount;
  final String? currency;
  final String transactionType;
  final String? status;
  final DateTime timestamp;
  final num? convertedAmount;
  final String? note;
  final WalletModel? fromWallet;
  final WalletModel? toWallet;
  final String? receiverName;
  final String? receiverPhoneNumber;
  final String? receiverBank;
  final String? receiverAccountNumber;
  final Map? pendingTransfer;
  final String? bankLastDigits;
  WalletTransactionModel({
    required this.transactionId,
    this.amount,
    this.currency,
    required this.transactionType,
    required this.status,
    required this.timestamp,
    this.convertedAmount,
    this.note,
    this.fromWallet,
    this.toWallet,
    this.receiverName,
    this.receiverPhoneNumber,
    this.receiverBank,
    this.receiverAccountNumber,
    this.pendingTransfer,
    this.bankLastDigits,
  });

  WalletTransactionModel copyWith({
    int? transactionId,
    num? amount,
    String? currency,
    String? transactionType,
    String? status,
    DateTime? timestamp,
    num? convertedAmount,
    String? note,
    WalletModel? fromCurrency,
    WalletModel? toCurrency,
    String? receiverName,
    String? receiverPhoneNumber,
    String? receiverBank,
    String? receiverAccountNumber,
    Map? pendingTransfer,
    String? bankLastDigits,
  }) {
    return WalletTransactionModel(
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      transactionType: transactionType ?? this.transactionType,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      note: note ?? this.note,
      fromWallet: fromCurrency ?? fromWallet,
      toWallet: toCurrency ?? toWallet,
      receiverName: receiverName ?? this.receiverName,
      receiverPhoneNumber: receiverPhoneNumber ?? this.receiverPhoneNumber,
      receiverBank: receiverBank ?? this.receiverBank,
      receiverAccountNumber:
          receiverAccountNumber ?? this.receiverAccountNumber,
      pendingTransfer: pendingTransfer ?? this.pendingTransfer,
      bankLastDigits: bankLastDigits,
    );
  }

  factory WalletTransactionModel.fromMap(Map map) {
    return WalletTransactionModel(
      transactionId: map['transactionId'] as int?,
      amount: map['amount'] != null ? map['amount'] as num : null,
      currency: map['currency'] != null ? map['currency'] as String : null,
      transactionType: map['transactionType'] as String,
      status: map['status'] as String?,
      timestamp: DateTime.parse(map['timestamp']),
      convertedAmount:
          map['convertedAmount'] != null ? map['convertedAmount'] as num : null,
      note: map['note'] != null ? map['note'] as String : null,
      fromWallet: map['fromWallet'] != null
          ? WalletModel.fromMap(map['fromWallet'] as Map)
          : null,
      toWallet: map['toWallet'] != null
          ? WalletModel.fromMap(map['toWallet'] as Map)
          : null,
      receiverName:
          map['receiverName'] != null ? map['receiverName'] as String : null,
      receiverPhoneNumber: map['receiverPhoneNumber'] != null
          ? map['receiverPhoneNumber'] as String
          : null,
      receiverBank: map['receiverBank'] != null
          ? map['receiverBank']['name'] as String
          : null,
      receiverAccountNumber: map['receiverAccountNumber'] != null
          ? map['receiverAccountNumber'] as String
          : null,
      pendingTransfer:
          map['pendingTransfer'] != null ? map['pendingTransfer'] as Map : null,
    );
  }

  String to(Map<int, String> contacts,
      {List<ContactStatusModel>? localContacts}) {
    if (transactionType == 'BANK_TO_WALLET') {
      return "You";
    } else if (transactionType == 'REMITTANCE') {
      return receiverName ?? receiverPhoneNumber ?? "_";
    } else if (transactionType == 'PENDING_TRANSFER') {
      localContacts ??= [];
      final contact = localContacts.where(
        (element) =>
            element.contactPhoneNumber ==
            pendingTransfer?["recipientPhoneNumber"],
      );
      return contact.isNotEmpty
          ? contact.first.contactName
          : pendingTransfer?["recipientPhoneNumber"] ?? "_";
    }
    return toWallet == null
        ? 'Unregistered User'
        : contacts[toWallet!.holder!.id] ??
            '${toWallet?.holder?.firstName ?? ''} ${toWallet?.holder?.lastName ?? ''}';
  }

  String get from {
    if (bankLastDigits != null) {
      return '**** **** $bankLastDigits';
    }
    return "_";
  }

  @override
  String toString() {
    return 'WalletTransactionModel(fromWalletId: ${fromWallet?.walletId}, toWalletId: ${toWallet?.walletId}, transactionId: $transactionId, amount: $amount, transactionType: $transactionType, transactionTimestamp: $timestamp, note: $note)';
  }
}
