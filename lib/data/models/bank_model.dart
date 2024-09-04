// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BankModel {
  final String bankName;
  final String? bankLogo;
  BankModel({
    required this.bankName,
    required this.bankLogo,
  });

  BankModel copyWith({
    String? bankName,
    String? bankLogo,
  }) {
    return BankModel(
      bankName: bankName ?? this.bankName,
      bankLogo: bankLogo ?? this.bankLogo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bankName': bankName,
      'bankLogo': bankLogo,
    };
  }

  factory BankModel.fromMap(Map map) {
    return BankModel(
      bankName: map['name'] as String,
      bankLogo: map['logoUrl'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory BankModel.fromJson(String source) =>
      BankModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'BankModel(bankName: $bankName, bankLogo: $bankLogo)';

  @override
  bool operator ==(covariant BankModel other) {
    if (identical(this, other)) return true;

    return other.bankName == bankName && other.bankLogo == bankLogo;
  }

  @override
  int get hashCode => bankName.hashCode ^ bankLogo.hashCode;
}
