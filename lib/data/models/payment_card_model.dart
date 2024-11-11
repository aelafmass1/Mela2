// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PaymentCardModel {
  final String id;
  final String cardBrand;
  final String last4Digits;
  final int expirationMonth;
  final int expirationYear;
  final bool? isDefault;
  PaymentCardModel({
    required this.id,
    required this.cardBrand,
    required this.last4Digits,
    required this.expirationMonth,
    required this.expirationYear,
    this.isDefault,
  });

  PaymentCardModel copyWith({
    String? id,
    String? cardBrand,
    String? last4Digits,
    int? expirationMonth,
    int? expirationYear,
    bool? isDefault,
  }) {
    return PaymentCardModel(
      id: id ?? this.id,
      cardBrand: cardBrand ?? this.cardBrand,
      last4Digits: last4Digits ?? this.last4Digits,
      expirationMonth: expirationMonth ?? this.expirationMonth,
      expirationYear: expirationYear ?? this.expirationYear,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'cardBrand': cardBrand,
      'last4Digits': last4Digits,
      'expirationMonth': expirationMonth,
      'expirationYear': expirationYear,
      'isDefault': isDefault,
    };
  }

  factory PaymentCardModel.fromMap(Map map) {
    return PaymentCardModel(
      id: map['id'] as String,
      cardBrand: map['cardBrand'] as String,
      last4Digits: map['last4Digits'] as String,
      expirationMonth: map['expirationMonth'] as int,
      expirationYear: map['expirationYear'] as int,
      isDefault: map['isDefault'] != null ? map['isDefault'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentCardModel.fromJson(String source) =>
      PaymentCardModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PaymentCardModel(id: $id, cardBrand: $cardBrand, last4Digits: $last4Digits, expirationMonth: $expirationMonth, expirationYear: $expirationYear, isDefault: $isDefault)';
  }

  @override
  bool operator ==(covariant PaymentCardModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.cardBrand == cardBrand &&
        other.last4Digits == last4Digits &&
        other.expirationMonth == expirationMonth &&
        other.expirationYear == expirationYear &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cardBrand.hashCode ^
        last4Digits.hashCode ^
        expirationMonth.hashCode ^
        expirationYear.hashCode ^
        isDefault.hashCode;
  }
}
