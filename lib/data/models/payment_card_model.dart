// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:transaction_mobile_app/data/models/bank_fee_model.dart';

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
  final List<BankFeeModel> fees; 

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
    required this.fees, 
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
    List<BankFeeModel>? fees, 
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
      fees: fees ?? this.fees, 
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
      'fees': fees.map((fee) => fee.toMap()).toList(),
    };
  }

  factory PaymentCardModel.fromMap(Map<String, dynamic> map) {
    return PaymentCardModel(
      id: map['id'] as String,
      type: map['type'] as String,
      cardBrand:map['cardBrand'] as String?,
      last4Digits: map['last4Digits'] as String?,
      expirationMonth: map['expirationMonth'] as int?,
      expirationYear: map['expirationYear'] as int?,
      isDefault: map['isDefault'] as bool?,
      bankName: map['bankName'] as String?,
      accountHolderName: map['accountHolderName'] as String?,
      accountHolderType: map['accountHolderType'] as String?,
      fees: (map['fees'] as List<dynamic>)
          .map((fee) => BankFeeModel.fromMap(fee as Map<String, dynamic>))
          .toList(), 
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentCardModel.fromJson(String source) =>
      PaymentCardModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PaymentCardModel(id: $id, type: $type, cardBrand: $cardBrand, last4Digits: $last4Digits, expirationMonth: $expirationMonth, expirationYear: $expirationYear, isDefault: $isDefault, bankName: $bankName, accountHolderName: $accountHolderName, accountHolderType: $accountHolderType, fees: $fees)'; // Updated toString
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
        other.accountHolderType == accountHolderType &&
        _areFeesEqual(other.fees); 
  }

  bool _areFeesEqual(List<BankFeeModel> otherFees) {
    if (fees.length != otherFees.length) return false;
    for (var i = 0; i < fees.length; i++) {
      if (fees[i] != otherFees[i]) return false;
    }
    return true;
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
        accountHolderType.hashCode ^
        fees.hashCode;
  }
}
