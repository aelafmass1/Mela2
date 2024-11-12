// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:transaction_mobile_app/data/models/wallet_currency_model.dart';

class WalletModel extends Equatable {
  final int walletId;
  final WalletCurrencyModel currency;
  final num balance;
  const WalletModel({
    required this.walletId,
    required this.currency,
    required this.balance,
  });

  WalletModel copyWith({
    int? walletId,
    WalletCurrencyModel? currency,
    num? balance,
  }) {
    return WalletModel(
      walletId: walletId ?? this.walletId,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'walletId': walletId,
      'currency': currency.toMap(),
      'balance': balance,
    };
  }

  factory WalletModel.fromMap(Map map) {
    return WalletModel(
      walletId: map['walletId'] as int,
      currency: WalletCurrencyModel.fromMap(map['currency'] as Map),
      balance: map['balance'] as num,
    );
  }

  String toJson() => json.encode(toMap());

  factory WalletModel.fromJson(String source) =>
      WalletModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [walletId, currency, balance];
}
