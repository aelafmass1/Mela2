// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PaymentCardModel {
  final String id;
  final String type;
  final String? cardBrand;
  final String? last4Digits;
  final int? expirationMonth;
  final int? expirationYear;
  final bool? isDefault;
  final String? bankName;
  final String? accountHolderName;
  final String? accountHolderType;
  PaymentCardModel({
    required this.id,
    required this.type,
    this.cardBrand,
    this.last4Digits,
    this.expirationMonth,
    this.expirationYear,
    this.isDefault,
    this.bankName,
    this.accountHolderName,
    this.accountHolderType,
  });

  PaymentCardModel copyWith({
    String? id,
    String? type,
    String? cardBrand,
    String? last4Digits,
    int? expirationMonth,
    int? expirationYear,
    bool? isDefault,
    String? bankName,
    String? accountHolderName,
    String? accountHolderType,
  }) {
    return PaymentCardModel(
      id: id ?? this.id,
      type: type ?? this.type,
      cardBrand: cardBrand ?? this.cardBrand,
      last4Digits: last4Digits ?? this.last4Digits,
      expirationMonth: expirationMonth ?? this.expirationMonth,
      expirationYear: expirationYear ?? this.expirationYear,
      isDefault: isDefault ?? this.isDefault,
      bankName: bankName ?? this.bankName,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountHolderType: accountHolderType ?? this.accountHolderType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'cardBrand': cardBrand,
      'last4Digits': last4Digits,
      'expirationMonth': expirationMonth,
      'expirationYear': expirationYear,
      'isDefault': isDefault,
      'bankName': bankName,
      'accountHolderName': accountHolderName,
      'accountHolderType': accountHolderType,
    };
  }

  factory PaymentCardModel.fromMap(Map<String, dynamic> map) {
    return PaymentCardModel(
      id: map['id'] as String,
      type: map['type'] as String,
      cardBrand: map['cardBrand'] != null ? map['cardBrand'] as String : null,
      last4Digits:
          map['last4Digits'] != null ? map['last4Digits'] as String : null,
      expirationMonth:
          map['expirationMonth'] != null ? map['expirationMonth'] as int : null,
      expirationYear:
          map['expirationYear'] != null ? map['expirationYear'] as int : null,
      isDefault: map['isDefault'] != null ? map['isDefault'] as bool : null,
      bankName: map['bankName'] != null ? map['bankName'] as String : null,
      accountHolderName: map['accountHolderName'] != null
          ? map['accountHolderName'] as String
          : null,
      accountHolderType: map['accountHolderType'] != null
          ? map['accountHolderType'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentCardModel.fromJson(String source) =>
      PaymentCardModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PaymentCardModel(id: $id, type: $type, cardBrand: $cardBrand, last4Digits: $last4Digits, expirationMonth: $expirationMonth, expirationYear: $expirationYear, isDefault: $isDefault, bankName: $bankName, accountHolderName: $accountHolderName, accountHolderType: $accountHolderType)';
  }

  @override
  bool operator ==(covariant PaymentCardModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.type == type &&
        other.cardBrand == cardBrand &&
        other.last4Digits == last4Digits &&
        other.expirationMonth == expirationMonth &&
        other.expirationYear == expirationYear &&
        other.isDefault == isDefault &&
        other.bankName == bankName &&
        other.accountHolderName == accountHolderName &&
        other.accountHolderType == accountHolderType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        cardBrand.hashCode ^
        last4Digits.hashCode ^
        expirationMonth.hashCode ^
        expirationYear.hashCode ^
        isDefault.hashCode ^
        bankName.hashCode ^
        accountHolderName.hashCode ^
        accountHolderType.hashCode;
  }
}
