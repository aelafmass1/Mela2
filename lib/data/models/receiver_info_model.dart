// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ReceiverInfo {
  final String senderUserId;
  final String receiverName;
  final String receiverPhoneNumber;
  final String receiverBankName;
  final String receiverAccountNumber;
  final double amount;
  ReceiverInfo({
    required this.senderUserId,
    required this.receiverName,
    required this.receiverPhoneNumber,
    required this.receiverBankName,
    required this.receiverAccountNumber,
    required this.amount,
  });

  ReceiverInfo copyWith({
    String? senderUserId,
    String? receiverName,
    String? receiverPhoneNumber,
    String? receiverBankName,
    String? receiverAccountNumber,
    double? amount,
  }) {
    return ReceiverInfo(
      senderUserId: senderUserId ?? this.senderUserId,
      receiverName: receiverName ?? this.receiverName,
      receiverPhoneNumber: receiverPhoneNumber ?? this.receiverPhoneNumber,
      receiverBankName: receiverBankName ?? this.receiverBankName,
      receiverAccountNumber:
          receiverAccountNumber ?? this.receiverAccountNumber,
      amount: amount ?? this.amount,
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
    };
  }

  factory ReceiverInfo.fromMap(Map<String, dynamic> map) {
    return ReceiverInfo(
      senderUserId: map['senderUserId'] as String,
      receiverName: map['receiverName'] as String,
      receiverPhoneNumber: map['receiverPhoneNumber'] as String,
      receiverBankName: map['receiverBankName'] as String,
      receiverAccountNumber: map['receiverAccountNumber'] as String,
      amount: map['amount'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReceiverInfo.fromJson(String source) =>
      ReceiverInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ReceiverInfoModel(senderUserId: $senderUserId, receiverName: $receiverName, receiverPhoneNumber: $receiverPhoneNumber, receiverBankName: $receiverBankName, receiverAccountNumber: $receiverAccountNumber, amount: $amount)';
  }

  @override
  bool operator ==(covariant ReceiverInfo other) {
    if (identical(this, other)) return true;

    return other.senderUserId == senderUserId &&
        other.receiverName == receiverName &&
        other.receiverPhoneNumber == receiverPhoneNumber &&
        other.receiverBankName == receiverBankName &&
        other.receiverAccountNumber == receiverAccountNumber &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return senderUserId.hashCode ^
        receiverName.hashCode ^
        receiverPhoneNumber.hashCode ^
        receiverBankName.hashCode ^
        receiverAccountNumber.hashCode ^
        amount.hashCode;
  }
}
