// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class WalletModel extends Equatable {
  final int walletId;
  final String currency;
  final num balance;
  final String? backgroundColor;
  final String? textColor;
  const WalletModel({
    required this.walletId,
    required this.currency,
    required this.balance,
    this.backgroundColor,
    this.textColor,
  });

  WalletModel copyWith({
    int? walletId,
    String? currency,
    num? balance,
    String? backgroundColor,
    String? textColor,
  }) {
    return WalletModel(
      walletId: walletId ?? this.walletId,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.backgroundColor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'walletId': walletId,
      'currency': currency,
      'balance': balance,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
    };
  }

  factory WalletModel.fromMap(Map map) {
    return WalletModel(
      walletId: map['walletId'] as int,
      currency: map['currency'] as String,
      balance: map['balance'] as num,
      backgroundColor: map['backgroundColor'],
      textColor: map['textColor'],
    );
  }

  String toJson() => json.encode(toMap());

  factory WalletModel.fromJson(String source) =>
      WalletModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'WalletModel(walletId: $walletId, currency: $currency, balance: $balance, backgroundColor: $backgroundColor, textColor: $textColor)';

  @override
  int get hashCode => walletId.hashCode ^ currency.hashCode ^ balance.hashCode;

  @override
  List<Object?> get props => [
        walletId,
        currency,
        balance,
        textColor,
        backgroundColor,
      ];
}
