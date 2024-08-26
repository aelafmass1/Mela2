// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CurrencyModel {
  final double rate;
  final String currencyCode;
  CurrencyModel({
    required this.rate,
    required this.currencyCode,
  });

  CurrencyModel copyWith({
    double? rate,
    String? currencyCode,
  }) {
    return CurrencyModel(
      rate: rate ?? this.rate,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rate': rate,
      'currencyCode': currencyCode,
    };
  }

  factory CurrencyModel.fromMap(Map<String, dynamic> map) {
    return CurrencyModel(
      rate: map['rate'] as double,
      currencyCode: map['currencyCode'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CurrencyModel.fromJson(String source) =>
      CurrencyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CurrencyModel(rate: $rate, currencyCode: $currencyCode)';

  @override
  bool operator ==(covariant CurrencyModel other) {
    if (identical(this, other)) return true;

    return other.rate == rate && other.currencyCode == currencyCode;
  }

  @override
  int get hashCode => rate.hashCode ^ currencyCode.hashCode;
}
