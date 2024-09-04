// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BankFeeModel {
  final int id;
  final String label;
  final String type;
  final double amount;
  final String paymentMethod;
  BankFeeModel({
    required this.id,
    required this.label,
    required this.type,
    required this.amount,
    required this.paymentMethod,
  });

  BankFeeModel copyWith({
    int? id,
    String? label,
    String? type,
    double? amount,
    String? paymentMethod,
  }) {
    return BankFeeModel(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'type': type,
      'amount': amount,
      'paymentMethod': paymentMethod,
    };
  }

  factory BankFeeModel.fromMap(Map<String, dynamic> map) {
    return BankFeeModel(
      id: map['id'] as int,
      label: map['label'] as String,
      type: map['type'] as String,
      amount: map['amount'] as double,
      paymentMethod: map['paymentMethod'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BankFeeModel.fromJson(String source) =>
      BankFeeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BankFeeModel(id: $id, label: $label, type: $type, amount: $amount, paymentMethod: $paymentMethod)';
  }

  @override
  bool operator ==(covariant BankFeeModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.label == label &&
        other.type == type &&
        other.amount == amount &&
        other.paymentMethod == paymentMethod;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        label.hashCode ^
        type.hashCode ^
        amount.hashCode ^
        paymentMethod.hashCode;
  }
}
