// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'wallet_model.dart';

class ContactStatusModel {
  final String contactId;
  final String contactStatus;
  final int userId;
  final List<WalletModel>? wallets;
  final String? contactName;
  final String? contactPhoneNumber;
  ContactStatusModel({
    required this.contactId,
    required this.contactStatus,
    required this.userId,
    this.wallets,
    this.contactName,
    this.contactPhoneNumber,
  });

  ContactStatusModel copyWith({
    String? contactId,
    String? contactStatus,
    int? userId,
    List<WalletModel>? wallets,
    String? contactName,
    String? contactPhoneNumber,
  }) {
    return ContactStatusModel(
      contactId: contactId ?? this.contactId,
      contactStatus: contactStatus ?? this.contactStatus,
      userId: userId ?? this.userId,
      wallets: wallets ?? this.wallets,
      contactName: contactName ?? this.contactName,
      contactPhoneNumber: contactPhoneNumber ?? this.contactPhoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'contactId': contactId,
      'contactStatus': contactStatus,
      'userId': userId,
      'wallets': wallets?.map((x) => x.toMap()).toList(),
      'contactName': contactName,
      'contactPhoneNumber': contactPhoneNumber,
    };
  }

  factory ContactStatusModel.fromMap(Map map) {
    return ContactStatusModel(
      contactId: map['contactId'] as String,
      contactStatus: map['contactStatus'] as String,
      userId: map['userId'] as int,
      wallets: map['wallets'] != null
          ? List<WalletModel>.from(
              (map['wallets'] as List).map<WalletModel?>(
                (x) => WalletModel.fromMap(x as Map),
              ),
            )
          : null,
      contactName:
          map['contactName'] != null ? map['contactName'] as String : null,
      contactPhoneNumber: map['contactPhoneNumber'] != null
          ? map['contactPhoneNumber'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContactStatusModel.fromJson(String source) =>
      ContactStatusModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ContactStatusModel(contactId: $contactId, contactStatus: $contactStatus, userId: $userId, wallets: $wallets, contactName: $contactName, contactPhoneNumber: $contactPhoneNumber)';
  }

  @override
  bool operator ==(covariant ContactStatusModel other) {
    if (identical(this, other)) return true;

    return other.contactId == contactId &&
        other.contactStatus == contactStatus &&
        other.userId == userId &&
        listEquals(other.wallets, wallets) &&
        other.contactName == contactName &&
        other.contactPhoneNumber == contactPhoneNumber;
  }

  @override
  int get hashCode {
    return contactId.hashCode ^
        contactStatus.hashCode ^
        userId.hashCode ^
        wallets.hashCode ^
        contactName.hashCode ^
        contactPhoneNumber.hashCode;
  }
}
