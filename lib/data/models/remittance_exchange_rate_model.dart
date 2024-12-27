// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'wallet_currency_model.dart';

class RemittanceExchangeRateModel {
  final WalletCurrencyModel fromCurrency;
  final WalletCurrencyModel toCurrency;
  final double rate;
  RemittanceExchangeRateModel({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
  });

  RemittanceExchangeRateModel copyWith({
    WalletCurrencyModel? fromCurrency,
    WalletCurrencyModel? toCurrency,
    double? rate,
  }) {
    return RemittanceExchangeRateModel(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      rate: rate ?? this.rate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fromCurrency': fromCurrency.toMap(),
      'toCurrency': toCurrency.toMap(),
      'rate': rate,
    };
  }

  factory RemittanceExchangeRateModel.fromMap(Map<String, dynamic> map) {
    return RemittanceExchangeRateModel(
      fromCurrency: WalletCurrencyModel.fromMap(
          map['fromCurrency'] as Map<String, dynamic>),
      toCurrency: WalletCurrencyModel.fromMap(
          map['toCurrency'] as Map<String, dynamic>),
      rate: map['rate'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory RemittanceExchangeRateModel.fromJson(String source) =>
      RemittanceExchangeRateModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'RemittanceExchangeRateModel(fromCurrency: $fromCurrency, toCurrency: $toCurrency, rate: $rate)';

  @override
  bool operator ==(covariant RemittanceExchangeRateModel other) {
    if (identical(this, other)) return true;

    return other.fromCurrency == fromCurrency &&
        other.toCurrency == toCurrency &&
        other.rate == rate;
  }

  @override
  int get hashCode =>
      fromCurrency.hashCode ^ toCurrency.hashCode ^ rate.hashCode;
}
