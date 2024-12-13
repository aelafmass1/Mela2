// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/data/models/wallet_model.dart';

class MoneyRequestModel {
  final int id;
  final num amount;
  final WalletModel requesterWalletId;
  final UserModel recipientId;
  final String? note;
  final bool? fulfilled;
  MoneyRequestModel({
    required this.id,
    required this.amount,
    required this.requesterWalletId,
    required this.recipientId,
    this.note,
    this.fulfilled,
  });

  MoneyRequestModel copyWith({
    int? id,
    num? amount,
    WalletModel? requesterWalletId,
    UserModel? recipientId,
    String? note,
    bool? fulfilled,
  }) {
    return MoneyRequestModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      requesterWalletId: requesterWalletId ?? this.requesterWalletId,
      recipientId: recipientId ?? this.recipientId,
      note: note ?? this.note,
      fulfilled: fulfilled ?? this.fulfilled,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'requesterWalletId': requesterWalletId.toMap(),
      'recipientId': recipientId.toMap(),
      'note': note,
      'fulfilled': fulfilled,
    };
  }

  factory MoneyRequestModel.fromMap(Map<String, dynamic> map) {
    return MoneyRequestModel(
      id: map['id'] as int,
      amount: map['amount'] as num,
      requesterWalletId: WalletModel.fromMap(map['requesterWalletId']),
      recipientId: UserModel.fromMap(map['recipientId']),
      note: map['note'] != null ? map['note'] as String : null,
      fulfilled: map['fulfilled'] != null ? map['fulfilled'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MoneyRequestModel.fromJson(String source) =>
      MoneyRequestModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MoneyRequestModel(id: $id, amount: $amount, requesterWalletId: $requesterWalletId, recipientId: $recipientId, note: $note, fulfilled: $fulfilled)';
  }

  @override
  bool operator ==(covariant MoneyRequestModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.amount == amount &&
        other.requesterWalletId == requesterWalletId &&
        other.recipientId == recipientId &&
        other.note == note &&
        other.fulfilled == fulfilled;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        requesterWalletId.hashCode ^
        recipientId.hashCode ^
        note.hashCode ^
        fulfilled.hashCode;
  }
}
