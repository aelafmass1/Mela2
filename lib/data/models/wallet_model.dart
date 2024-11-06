// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class WalletModel {
  final int walletId;
  final String currency;
  final num balance;
  WalletModel({
    required this.walletId,
    required this.currency,
    required this.balance,
  });

  WalletModel copyWith({
    int? walletId,
    String? currency,
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
      'currency': currency,
      'balance': balance,
    };
  }

  factory WalletModel.fromMap(Map map) {
    return WalletModel(
      walletId: map['walletId'] as int,
      currency: map['currency'] as String,
      balance: map['balance'] as num,
    );
  }

  String toJson() => json.encode(toMap());

  factory WalletModel.fromJson(String source) =>
      WalletModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'WalletModel(walletId: $walletId, currency: $currency, balance: $balance)';

  @override
  bool operator ==(covariant WalletModel other) {
    if (identical(this, other)) return true;

    return other.walletId == walletId &&
        other.currency == currency &&
        other.balance == balance;
  }

  @override
  int get hashCode => walletId.hashCode ^ currency.hashCode ^ balance.hashCode;
}
