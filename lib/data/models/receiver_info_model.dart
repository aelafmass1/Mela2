// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ReceiverInfo {
  final String receiverName;
  final String receiverPhoneNumber;
  final String receiverBankName;
  final String receiverAccountNumber;
  final double amount;
  final String? serviceChargePayer;
  final DateTime? transactionDate;
  final String? publicToken;
  final String paymentType;
  final String? lastDigit;
  final String? details;
  final String? transactionId;
  ReceiverInfo({
    required this.receiverName,
    required this.receiverPhoneNumber,
    required this.receiverBankName,
    required this.receiverAccountNumber,
    required this.amount,
    this.serviceChargePayer,
    this.transactionDate,
    this.publicToken,
    required this.paymentType,
    this.details,
    this.lastDigit,
    this.transactionId,
  });

  ReceiverInfo copyWith({
    String? receiverName,
    String? receiverPhoneNumber,
    String? receiverBankName,
    String? receiverAccountNumber,
    double? amount,
    String? serviceChargePayer,
    DateTime? trasactionDate,
    String? publicToken,
    String? paymentType,
    final String? lastDigit,
    final String? details,
    final String? transactionId,
  }) {
    return ReceiverInfo(
      receiverName: receiverName ?? this.receiverName,
      receiverPhoneNumber: receiverPhoneNumber ?? this.receiverPhoneNumber,
      receiverBankName: receiverBankName ?? this.receiverBankName,
      receiverAccountNumber:
          receiverAccountNumber ?? this.receiverAccountNumber,
      amount: amount ?? this.amount,
      serviceChargePayer: serviceChargePayer ?? this.serviceChargePayer,
      transactionDate: trasactionDate ?? transactionDate,
      publicToken: publicToken ?? this.publicToken,
      paymentType: paymentType ?? this.paymentType,
      details: details ?? this.details,
      lastDigit: lastDigit ?? this.lastDigit,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'receiverName': receiverName,
      'receiverPhoneNumber': receiverPhoneNumber,
      'receiverBankName': receiverBankName,
      'receiverAccountNumber': receiverAccountNumber,
      'amount': amount,
      'serviceChargePayer': serviceChargePayer,
      'trasactionDate': transactionDate?.millisecondsSinceEpoch,
      'publicToken': publicToken,
      'paymentType': paymentType,
    };
  }

  factory ReceiverInfo.fromMap(Map<String, dynamic> map) {
    return ReceiverInfo(
      receiverName: map['receiverName'] as String,
      receiverPhoneNumber: map['receiverPhoneNumber'] as String,
      receiverBankName: map['receiverBank']['name'] as String,
      receiverAccountNumber: map['receiverAccountNumber'] as String,
      amount: map['amount'] as double,
      serviceChargePayer: map['serviceChargePayer'] != null
          ? map['serviceChargePayer'] as String
          : null,
      transactionDate: map['transactionDate'] != null
          ? DateTime.parse(map['transactionDate'])
          : null,
      publicToken:
          map['publicToken'] != null ? map['publicToken'] as String : null,
      paymentType: map['paymentType'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ReceiverInfo.fromJson(String source) =>
      ReceiverInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ReceiverInfo(receiverName: $receiverName, receiverPhoneNumber: $receiverPhoneNumber, receiverBankName: $receiverBankName, receiverAccountNumber: $receiverAccountNumber, amount: $amount, serviceChargePayer: $serviceChargePayer, trasactionDate: $transactionDate, publicToken: $publicToken, paymentType: $paymentType)';
  }

  @override
  bool operator ==(covariant ReceiverInfo other) {
    if (identical(this, other)) return true;

    return other.receiverName == receiverName &&
        other.receiverPhoneNumber == receiverPhoneNumber &&
        other.receiverBankName == receiverBankName &&
        other.receiverAccountNumber == receiverAccountNumber &&
        other.amount == amount &&
        other.serviceChargePayer == serviceChargePayer &&
        other.transactionDate == transactionDate &&
        other.publicToken == publicToken &&
        other.paymentType == paymentType;
  }

  @override
  int get hashCode {
    return receiverName.hashCode ^
        receiverPhoneNumber.hashCode ^
        receiverBankName.hashCode ^
        receiverAccountNumber.hashCode ^
        amount.hashCode ^
        serviceChargePayer.hashCode ^
        transactionDate.hashCode ^
        publicToken.hashCode ^
        paymentType.hashCode;
  }
}
