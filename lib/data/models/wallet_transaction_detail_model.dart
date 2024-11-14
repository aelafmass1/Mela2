// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:transaction_mobile_app/data/models/equb_member_model.dart';
import 'package:transaction_mobile_app/data/models/wallet_currency_model.dart';

class WalletTransactionDetailModel {
  final int transactionId;
  final num? amount;
  final String? currency;
  final String transactionType;
  final String status;
  final DateTime timestamp;
  final num? convertedAmount;
  final String? note;
  final MelaUser? toUser;
  final WalletCurrencyModel? fromCurrency;
  final WalletCurrencyModel? toCurrency;
  WalletTransactionDetailModel({
    required this.transactionId,
    this.amount,
    this.currency,
    required this.transactionType,
    required this.status,
    required this.timestamp,
    this.convertedAmount,
    this.note,
    this.toUser,
    this.fromCurrency,
    this.toCurrency,
  });

  WalletTransactionDetailModel copyWith({
    int? transactionId,
    num? amount,
    String? currency,
    String? transactionType,
    String? status,
    DateTime? timestamp,
    num? convertedAmount,
    String? note,
    MelaUser? toUser,
    WalletCurrencyModel? fromCurrency,
    WalletCurrencyModel? toCurrency,
  }) {
    return WalletTransactionDetailModel(
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      transactionType: transactionType ?? this.transactionType,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      note: note ?? this.note,
      toUser: toUser ?? this.toUser,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'transactionId': transactionId,
      'amount': amount,
      'currency': currency,
      'transactionType': transactionType,
      'status': status,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'convertedAmount': convertedAmount,
      'note': note,
      'toUser': toUser?.toMap(),
      'fromCurrency': fromCurrency?.toMap(),
      'toCurrency': toCurrency?.toMap(),
    };
  }

  factory WalletTransactionDetailModel.fromMap(Map map) {
    return WalletTransactionDetailModel(
      transactionId: map['transactionId'] as int,
      amount: map['amount'] != null ? map['amount'] as num : null,
      currency: map['currency'] != null ? map['currency'] as String : null,
      transactionType: map['transactionType'] as String,
      status: map['status'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      convertedAmount:
          map['convertedAmount'] != null ? map['convertedAmount'] as num : null,
      note: map['note'] != null ? map['note'] as String : null,
      toUser: map['toUser'] != null
          ? MelaUser.fromMap(map['toUser'] as Map<String, dynamic>)
          : null,
      fromCurrency: map['fromCurrency'] != null
          ? WalletCurrencyModel.fromMap(
              map['fromCurrency'] as Map<String, dynamic>)
          : null,
      toCurrency: map['toCurrency'] != null
          ? WalletCurrencyModel.fromMap(
              map['toCurrency'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory WalletTransactionDetailModel.fromJson(String source) =>
      WalletTransactionDetailModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WalletTransactionDetailModel(transactionId: $transactionId, amount: $amount, currency: $currency, transactionType: $transactionType, status: $status, timestamp: $timestamp, convertedAmount: $convertedAmount, note: $note, toUser: $toUser, fromCurrency: $fromCurrency, toCurrency: $toCurrency)';
  }

  @override
  bool operator ==(covariant WalletTransactionDetailModel other) {
    if (identical(this, other)) return true;

    return other.transactionId == transactionId &&
        other.amount == amount &&
        other.currency == currency &&
        other.transactionType == transactionType &&
        other.status == status &&
        other.timestamp == timestamp &&
        other.convertedAmount == convertedAmount &&
        other.note == note &&
        other.toUser == toUser &&
        other.fromCurrency == fromCurrency &&
        other.toCurrency == toCurrency;
  }

  @override
  int get hashCode {
    return transactionId.hashCode ^
        amount.hashCode ^
        currency.hashCode ^
        transactionType.hashCode ^
        status.hashCode ^
        timestamp.hashCode ^
        convertedAmount.hashCode ^
        note.hashCode ^
        toUser.hashCode ^
        fromCurrency.hashCode ^
        toCurrency.hashCode;
  }
}
