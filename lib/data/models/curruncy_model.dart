// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CurrencyModel {
  final double amount;
  CurrencyModel({
    required this.amount,
  });

  CurrencyModel copyWith({
    double? amount,
  }) {
    return CurrencyModel(
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'amount': amount,
    };
  }

  factory CurrencyModel.fromMap(Map<String, dynamic> map) {
    return CurrencyModel(
      amount: map['amount'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory CurrencyModel.fromJson(String source) =>
      CurrencyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CurruncyModel(amount: $amount)';

  @override
  bool operator ==(covariant CurrencyModel other) {
    if (identical(this, other)) return true;

    return other.amount == amount;
  }

  @override
  int get hashCode => amount.hashCode;
}
