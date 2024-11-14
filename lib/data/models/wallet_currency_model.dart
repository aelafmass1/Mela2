// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:transaction_mobile_app/data/models/equb_member_model.dart';

class WalletCurrencyModel {
  final int id;
  final String code;
  final String label;
  final String? backgroundColor;
  final String? textColor;
  final MelaUser? holder;
  WalletCurrencyModel({
    required this.id,
    required this.code,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.holder,
  });

  WalletCurrencyModel copyWith({
    int? id,
    String? code,
    String? label,
    String? backgroundColor,
    String? textColor,
    MelaUser? holder,
  }) {
    return WalletCurrencyModel(
      id: id ?? this.id,
      code: code ?? this.code,
      label: label ?? this.label,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      holder: holder ?? this.holder,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'label': label,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'holder': holder?.toMap(),
    };
  }

  factory WalletCurrencyModel.fromMap(Map map) {
    return WalletCurrencyModel(
      id: map['id'] as int,
      code: map['code'] as String,
      label: map['label'] as String,
      backgroundColor: map['backgroundColor'] != null
          ? map['backgroundColor'] as String
          : null,
      textColor: map['textColor'] != null ? map['textColor'] as String : null,
      holder: map['holder'] != null
          ? MelaUser.fromMap(map['holder'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory WalletCurrencyModel.fromJson(String source) =>
      WalletCurrencyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WalletCurrencyModel(id: $id, code: $code, label: $label, backgroundColor: $backgroundColor, textColor: $textColor, holder: $holder)';
  }

  @override
  bool operator ==(covariant WalletCurrencyModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.code == code &&
        other.label == label &&
        other.backgroundColor == backgroundColor &&
        other.textColor == textColor &&
        other.holder == holder;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        code.hashCode ^
        label.hashCode ^
        backgroundColor.hashCode ^
        textColor.hashCode ^
        holder.hashCode;
  }
}
