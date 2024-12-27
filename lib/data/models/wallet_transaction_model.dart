// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class WalletTransactionModel {
  final int fromWalletId;
  final int? toWalletId;
  final int transactionId;
  final num? fromWalletBalance;
  final num amount;
  final String? transactionType;
  final DateTime timestamp;
  final String? note;
  final String? from;
  final String? to;
  WalletTransactionModel({
    required this.fromWalletId,
    required this.toWalletId,
    required this.transactionId,
    required this.fromWalletBalance,
    required this.amount,
    required this.transactionType,
    required this.timestamp,
    required this.note,
    this.from,
    this.to,
  });

  WalletTransactionModel copyWith({
    int? fromWalletId,
    int? toWalletId,
    int? transactionId,
    num? fromWalletBalance,
    num? amount,
    String? transactionType,
    DateTime? transactionTimestamp,
    String? note,
  }) {
    return WalletTransactionModel(
      fromWalletId: fromWalletId ?? this.fromWalletId,
      toWalletId: toWalletId ?? this.toWalletId,
      transactionId: transactionId ?? this.transactionId,
      fromWalletBalance: fromWalletBalance ?? this.fromWalletBalance,
      amount: amount ?? this.amount,
      transactionType: transactionType ?? this.transactionType,
      timestamp: transactionTimestamp ?? timestamp,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fromWalletId': fromWalletId,
      'toWalletId': toWalletId,
      'transactionId': transactionId,
      'fromWalletBalance': fromWalletBalance,
      'amount': amount,
      'transactionType': transactionType,
      'transactionTimestamp': timestamp.millisecondsSinceEpoch,
      'note': note,
    };
  }

  factory WalletTransactionModel.fromMap(Map map) {
    return WalletTransactionModel(
      fromWalletId: map['fromWallet']['walletId'] as int,
      toWalletId:
          map['toWallet'] != null ? (map['toWallet']['walletId'] as int) : null,
      transactionId: map['transactionId'] as int,
      fromWalletBalance: map['fromWalletBalance'] as num?,
      amount: map['amount'] as num,
      transactionType: map['transactionType'] as String?,
      timestamp: DateTime.parse(map['timestamp']),
      note: map['note'] as String?,
      to: map['name'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory WalletTransactionModel.fromJson(String source) =>
      WalletTransactionModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WalletTransactionModel(fromWalletId: $fromWalletId, toWalletId: $toWalletId, transactionId: $transactionId, fromWalletBalance: $fromWalletBalance, amount: $amount, transactionType: $transactionType, transactionTimestamp: $timestamp, note: $note)';
  }

  @override
  bool operator ==(covariant WalletTransactionModel other) {
    if (identical(this, other)) return true;

    return other.fromWalletId == fromWalletId &&
        other.toWalletId == toWalletId &&
        other.transactionId == transactionId &&
        other.fromWalletBalance == fromWalletBalance &&
        other.amount == amount &&
        other.transactionType == transactionType &&
        other.timestamp == timestamp &&
        other.note == note;
  }

  @override
  int get hashCode {
    return fromWalletId.hashCode ^
        toWalletId.hashCode ^
        transactionId.hashCode ^
        fromWalletBalance.hashCode ^
        amount.hashCode ^
        transactionType.hashCode ^
        timestamp.hashCode ^
        note.hashCode;
  }
}
