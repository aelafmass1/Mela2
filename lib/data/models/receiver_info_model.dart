// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ReceiverInfo {
  final String senderUserId;
  final String receiverName;
  final String receiverPhoneNumber;
  final String receiverBankName;
  final String receiverAccountNumber;
  final double amount;
  final String? serviceChargePayer;
  final DateTime? trasactionDate;
  ReceiverInfo({
    required this.senderUserId,
    required this.receiverName,
    required this.receiverPhoneNumber,
    required this.receiverBankName,
    required this.receiverAccountNumber,
    required this.amount,
    this.serviceChargePayer,
    this.trasactionDate,
  });

  ReceiverInfo copyWith({
    String? senderUserId,
    String? receiverName,
    String? receiverPhoneNumber,
    String? receiverBankName,
    String? receiverAccountNumber,
    double? amount,
    String? serviceChargePayer,
    DateTime? trasactionDate,
  }) {
    return ReceiverInfo(
      senderUserId: senderUserId ?? this.senderUserId,
      receiverName: receiverName ?? this.receiverName,
      receiverPhoneNumber: receiverPhoneNumber ?? this.receiverPhoneNumber,
      receiverBankName: receiverBankName ?? this.receiverBankName,
      receiverAccountNumber:
          receiverAccountNumber ?? this.receiverAccountNumber,
      amount: amount ?? this.amount,
      serviceChargePayer: serviceChargePayer ?? this.serviceChargePayer,
      trasactionDate: trasactionDate ?? this.trasactionDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderUserId': senderUserId,
      'receiverName': receiverName,
      'receiverPhoneNumber': receiverPhoneNumber,
      'receiverBankName': receiverBankName,
      'receiverAccountNumber': receiverAccountNumber,
      'amount': amount,
      'serviceChargePayer': serviceChargePayer,
      'trasactionDate': trasactionDate?.millisecondsSinceEpoch,
    };
  }

  factory ReceiverInfo.fromMap(Map<String, dynamic> map) {
    return ReceiverInfo(
      senderUserId: map['senderUserId'] as String,
      receiverName: map['receiverName'] as String,
      receiverPhoneNumber: map['receiverPhoneNumber'] as String,
      receiverBankName: map['receiverBank']['name'] as String,
      receiverAccountNumber: map['receiverAccountNumber'] as String,
      amount: map['amount'] as double,
      serviceChargePayer: map['serviceChargePayer'] != null
          ? map['serviceChargePayer'] as String
          : null,
      trasactionDate: map["transactionDate"] != null
          ? DateTime.parse(map["transactionDate"])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReceiverInfo.fromJson(String source) =>
      ReceiverInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ReceiverInfo(senderUserId: $senderUserId, receiverName: $receiverName, receiverPhoneNumber: $receiverPhoneNumber, receiverBankName: $receiverBankName, receiverAccountNumber: $receiverAccountNumber, amount: $amount, serviceChargePayer: $serviceChargePayer, trasactionDate: $trasactionDate)';
  }

  @override
  bool operator ==(covariant ReceiverInfo other) {
    if (identical(this, other)) return true;

    return other.senderUserId == senderUserId &&
        other.receiverName == receiverName &&
        other.receiverPhoneNumber == receiverPhoneNumber &&
        other.receiverBankName == receiverBankName &&
        other.receiverAccountNumber == receiverAccountNumber &&
        other.amount == amount &&
        other.serviceChargePayer == serviceChargePayer &&
        other.trasactionDate == trasactionDate;
  }

  @override
  int get hashCode {
    return senderUserId.hashCode ^
        receiverName.hashCode ^
        receiverPhoneNumber.hashCode ^
        receiverBankName.hashCode ^
        receiverAccountNumber.hashCode ^
        amount.hashCode ^
        serviceChargePayer.hashCode ^
        trasactionDate.hashCode;
  }
}
