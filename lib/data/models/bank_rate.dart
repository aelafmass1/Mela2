// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BankRate {
  final String bankName;
  final num? buyingRate;
  final num? sellingRate;
  final String incrementPercentage;
  final String buyingRateChange;
  final String sellingRateChange;
  BankRate({
    required this.bankName,
    this.buyingRate,
    this.sellingRate,
    required this.incrementPercentage,
    required this.buyingRateChange,
    required this.sellingRateChange,
  });

  BankRate copyWith({
    String? bankName,
    num? buyingRate,
    num? sellingRate,
    String? incrementPercentage,
    String? buyingRateChange,
    String? sellingRateChange,
  }) {
    return BankRate(
      bankName: bankName ?? this.bankName,
      buyingRate: buyingRate ?? this.buyingRate,
      sellingRate: sellingRate ?? this.sellingRate,
      incrementPercentage: incrementPercentage ?? this.incrementPercentage,
      buyingRateChange: buyingRateChange ?? this.buyingRateChange,
      sellingRateChange: sellingRateChange ?? this.sellingRateChange,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bankName': bankName,
      'buyingRate': buyingRate,
      'sellingRate': sellingRate,
      'incrementPercentage': incrementPercentage,
      'buyingRateChange': buyingRateChange,
      'sellingRateChange': sellingRateChange,
    };
  }

  factory BankRate.fromMap(Map<String, dynamic> map) {
    return BankRate(
      bankName: map['bank_name'] as String,
      buyingRate: map['buying_rate'] != null ? map['buying_rate'] as num : null,
      sellingRate:
          map['selling_rate'] != null ? map['selling_rate'] as num : null,
      incrementPercentage: map['incrementPercentage'] as String,
      buyingRateChange: map['buyingRateChange'] as String,
      sellingRateChange: map['sellingRateChange'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BankRate.fromJson(String source) =>
      BankRate.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BankRate(bankName: $bankName, buyingRate: $buyingRate, sellingRate: $sellingRate, incrementPercentage: $incrementPercentage, buyingRateChange: $buyingRateChange, sellingRateChange: $sellingRateChange)';
  }

  @override
  bool operator ==(covariant BankRate other) {
    if (identical(this, other)) return true;

    return other.bankName == bankName &&
        other.buyingRate == buyingRate &&
        other.sellingRate == sellingRate &&
        other.incrementPercentage == incrementPercentage &&
        other.buyingRateChange == buyingRateChange &&
        other.sellingRateChange == sellingRateChange;
  }

  @override
  int get hashCode {
    return bankName.hashCode ^
        buyingRate.hashCode ^
        sellingRate.hashCode ^
        incrementPercentage.hashCode ^
        buyingRateChange.hashCode ^
        sellingRateChange.hashCode;
  }
}
