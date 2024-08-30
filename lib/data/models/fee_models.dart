// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class FeeModel {
  final int id;
  final String label;
  final String type;
  final double amount;
  FeeModel({
    required this.id,
    required this.label,
    required this.type,
    required this.amount,
  });

  FeeModel copyWith({
    int? id,
    String? label,
    String? type,
    double? amount,
  }) {
    return FeeModel(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'type': type,
      'amount': amount,
    };
  }

  factory FeeModel.fromMap(Map map) {
    return FeeModel(
      id: map['id'] as int,
      label: map['label'] as String,
      type: map['type'] as String,
      amount: map['amount'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory FeeModel.fromJson(String source) =>
      FeeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FeeModels(id: $id, label: $label, type: $type, amount: $amount)';
  }

  @override
  bool operator ==(covariant FeeModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.label == label &&
        other.type == type &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return id.hashCode ^ label.hashCode ^ type.hashCode ^ amount.hashCode;
  }
}
