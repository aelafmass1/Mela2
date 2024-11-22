// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:transaction_mobile_app/data/models/wallet_currency_model.dart';

import 'equb_member_model.dart';

class WalletModel {
  final int walletId;
  final WalletCurrencyModel currency;
  final num? balance;
  final MelaUser? holder;
  const WalletModel({
    required this.walletId,
    required this.currency,
    required this.balance,
    this.holder,
  });

  WalletModel copyWith({
    int? walletId,
    WalletCurrencyModel? currency,
    num? balance,
    MelaUser? holder,
  }) {
    return WalletModel(
      walletId: walletId ?? this.walletId,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      holder: holder ?? this.holder,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'walletId': walletId,
      'currency': currency.toMap(),
      'balance': balance,
      'holder': holder?.toMap(),
    };
  }

  factory WalletModel.fromMap(Map map) {
    return WalletModel(
      walletId: map['walletId'] as int,
      currency: WalletCurrencyModel.fromMap(map['currency'] as Map),
      balance: map['balance'] as num?,
      holder:
          map['holder'] != null ? MelaUser.fromMap(map['holder'] as Map) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory WalletModel.fromJson(String source) =>
      WalletModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
