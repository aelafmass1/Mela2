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
  final ExchangeRateModel? exchangeRate;
  final MelaUser? toUser;
  WalletTransactionDetailModel({
    required this.transactionId,
    this.amount,
    this.currency,
    required this.transactionType,
    required this.status,
    required this.timestamp,
    this.convertedAmount,
    this.note,
    this.exchangeRate,
    this.toUser,
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
    ExchangeRateModel? exchangeRate,
    MelaUser? toUser,
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
      exchangeRate: exchangeRate ?? this.exchangeRate,
      toUser: toUser ?? this.toUser,
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
      'exchangeRate': exchangeRate?.toMap(),
      'toUser': toUser?.toMap(),
    };
  }

  factory WalletTransactionDetailModel.fromMap(Map map) {
    return WalletTransactionDetailModel(
      transactionId: map['transactionId'] as int,
      amount: map['amount'] != null ? map['amount'] as num : null,
      currency: map['currency'] != null ? map['currency'] as String : null,
      transactionType: map['transactionType'] as String,
      status: map['status'] as String,
      timestamp: DateTime.parse(map['timestamp']),
      convertedAmount:
          map['convertedAmount'] != null ? map['convertedAmount'] as num : null,
      note: map['note'] != null ? map['note'] as String : null,
      exchangeRate: map['exchangeRate'] != null
          ? ExchangeRateModel.fromMap(map['exchangeRate'] as Map)
          : null,
      toUser:
          map['toUser'] != null ? MelaUser.fromMap(map['toUser'] as Map) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory WalletTransactionDetailModel.fromJson(String source) =>
      WalletTransactionDetailModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WalletTransactionDetailModel(transactionId: $transactionId, amount: $amount, currency: $currency, transactionType: $transactionType, status: $status, timestamp: $timestamp, convertedAmount: $convertedAmount, note: $note, exchangeRate: $exchangeRate, toUser: $toUser)';
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
        other.exchangeRate == exchangeRate &&
        other.toUser == toUser;
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
        exchangeRate.hashCode ^
        toUser.hashCode;
  }
}

class ExchangeRateModel {
  final int id;
  final num rate;
  final WalletCurrencyModel? fromCurrency;
  final WalletCurrencyModel? toCurrency;
  ExchangeRateModel({
    required this.id,
    required this.rate,
    this.fromCurrency,
    this.toCurrency,
  });

  ExchangeRateModel copyWith({
    int? id,
    num? rate,
    WalletCurrencyModel? fromCurrency,
    WalletCurrencyModel? toCurrency,
  }) {
    return ExchangeRateModel(
      id: id ?? this.id,
      rate: rate ?? this.rate,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'rate': rate,
      'fromCurrency': fromCurrency?.toMap(),
      'toCurrency': toCurrency?.toMap(),
    };
  }

  factory ExchangeRateModel.fromMap(Map map) {
    return ExchangeRateModel(
      id: map['id'] as int,
      rate: map['rate'] as num,
      fromCurrency: map['fromCurrency'] != null
          ? WalletCurrencyModel.fromMap(map['fromCurrency'] as Map)
          : null,
      toCurrency: map['toCurrency'] != null
          ? WalletCurrencyModel.fromMap(map['toCurrency'] as Map)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExchangeRateModel.fromJson(String source) =>
      ExchangeRateModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ExchangeRateModel(id: $id, rate: $rate, fromCurrency: $fromCurrency, toCurrency: $toCurrency)';
  }

  @override
  bool operator ==(covariant ExchangeRateModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.rate == rate &&
        other.fromCurrency == fromCurrency &&
        other.toCurrency == toCurrency;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        rate.hashCode ^
        fromCurrency.hashCode ^
        toCurrency.hashCode;
  }
}
